import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../models/study_session.dart';
import '../models/task.dart';
import '../services/notification_service.dart';
import 'sessions_provider.dart';
import 'settings_provider.dart';
import 'tasks_provider.dart';

enum TimerPhase { focus, shortBreak, longBreak }

enum TimerStatus { idle, running, paused }

/// Pomodoro state machine.
///
/// The remaining time is always derived from an absolute end time, so it stays
/// correct when the OS pauses the app. A system notification is scheduled only
/// while the app is in the background.
class TimerController extends ChangeNotifier with WidgetsBindingObserver {
  TimerController({
    required this.settings,
    required this.tasks,
    required this.sessions,
    NotificationService? notifications,
  }) : _notifications = notifications ?? NotificationService.instance {
    WidgetsBinding.instance.addObserver(this);
    settings.addListener(_onSettingsChanged);
    _resetPhaseTime();
  }

  final SettingsProvider settings;
  final TasksProvider tasks;
  final SessionsProvider sessions;
  final NotificationService _notifications;
  final AudioPlayer _player = AudioPlayer();

  TimerPhase phase = TimerPhase.focus;
  TimerStatus status = TimerStatus.idle;

  /// Focus sessions finished in the current cycle (0..sessionsBeforeLongBreak).
  int completedFocus = 0;

  String? selectedTaskId;

  int _phaseTotalMs = 0;
  int _remainingMs = 0; // valid while not running
  DateTime? _endAt; // valid while running
  DateTime? _focusStartedAt;
  Timer? _ticker;
  bool _foreground = true;

  // ---- derived values -----------------------------------------------------

  int get sessionsPerCycle => settings.settings.sessionsBeforeLongBreak;

  Task? get selectedTask {
    final t = tasks.byId(selectedTaskId);
    return (t == null || t.done) ? null : t;
  }

  int get remainingMs {
    if (status == TimerStatus.running && _endAt != null) {
      return math.max(0, _endAt!.difference(DateTime.now()).inMilliseconds);
    }
    return _remainingMs;
  }

  int get remainingSeconds => (remainingMs / 1000).ceil();
  int get totalSeconds => (_phaseTotalMs / 1000).round();

  /// 1.0 = full, 0.0 = finished.
  double get fraction =>
      _phaseTotalMs == 0 ? 0 : (remainingMs / _phaseTotalMs).clamp(0.0, 1.0);

  String get phaseTitle {
    switch (phase) {
      case TimerPhase.focus:
        return 'Focus';
      case TimerPhase.shortBreak:
        return 'Short break';
      case TimerPhase.longBreak:
        return 'Long break';
    }
  }

  int get upNextSession =>
      phase == TimerPhase.longBreak ? 1 : completedFocus + 1;

  int _phaseSeconds(TimerPhase p) {
    final s = settings.settings;
    switch (p) {
      case TimerPhase.focus:
        return s.focusMinutes * 60;
      case TimerPhase.shortBreak:
        return s.shortBreakMinutes * 60;
      case TimerPhase.longBreak:
        return s.longBreakMinutes * 60;
    }
  }

  void _resetPhaseTime() {
    _phaseTotalMs = _phaseSeconds(phase) * 1000;
    _remainingMs = _phaseTotalMs;
  }

  // ---- user actions -------------------------------------------------------

  void selectTask(String? id) {
    selectedTaskId = id;
    notifyListeners();
  }

  void startOrPause() {
    if (status == TimerStatus.running) {
      pause();
    } else {
      start();
    }
  }

  void start() {
    if (status == TimerStatus.running) return;
    if (phase == TimerPhase.focus && _focusStartedAt == null) {
      _focusStartedAt = DateTime.now();
    }
    _endAt = DateTime.now().add(Duration(milliseconds: _remainingMs));
    status = TimerStatus.running;
    _startTicker();
    notifyListeners();
  }

  void pause() {
    if (status != TimerStatus.running) return;
    _remainingMs = remainingMs;
    _endAt = null;
    status = TimerStatus.paused;
    _stopTicker();
    _notifications.cancel();
    notifyListeners();
  }

  void reset() {
    _stopTicker();
    _notifications.cancel();
    _endAt = null;
    status = TimerStatus.idle;
    _focusStartedAt = null;
    _resetPhaseTime();
    notifyListeners();
  }

  /// Jump to the next phase without recording anything.
  void skip() {
    final wasRunning = status == TimerStatus.running;
    _stopTicker();
    _notifications.cancel();
    if (phase == TimerPhase.longBreak) completedFocus = 0;
    _enterNextPhase(autoStart: wasRunning);
  }

  // ---- phase transitions --------------------------------------------------

  void _enterNextPhase({required bool autoStart}) {
    if (phase == TimerPhase.focus) {
      phase = completedFocus >= sessionsPerCycle
          ? TimerPhase.longBreak
          : TimerPhase.shortBreak;
    } else {
      phase = TimerPhase.focus;
    }
    _endAt = null;
    status = TimerStatus.idle;
    _focusStartedAt = null;
    _resetPhaseTime();
    if (autoStart) {
      start();
    } else {
      notifyListeners();
    }
  }

  void _onPhaseEnd() {
    final endedAt = _endAt ?? DateTime.now();
    final inBackground = !_foreground;
    _stopTicker();

    if (phase == TimerPhase.focus) {
      _recordSession(endedAt);
      completedFocus++;
    } else if (phase == TimerPhase.longBreak) {
      completedFocus = 0;
    }

    if (!inBackground) {
      _alertInForeground();
    }
    // In the background the notification tells the user; the next phase waits
    // (paused) until they come back.
    _enterNextPhase(autoStart: !inBackground);
  }

  void _recordSession(DateTime endedAt) {
    final seconds = totalSeconds;
    final task = selectedTask;
    sessions.add(StudySession(
      id: '',
      taskId: task?.id,
      taskTitle: task?.title,
      startedAt: _focusStartedAt ?? endedAt.subtract(Duration(seconds: seconds)),
      durationSeconds: seconds,
    ));
  }

  Future<void> _alertInForeground() async {
    final s = settings.settings;
    if (s.vibration) HapticFeedback.vibrate();
    if (s.volume > 0) {
      try {
        await _player.setVolume(s.volume);
        await _player.play(AssetSource('sounds/bell.wav'));
      } catch (_) {}
    }
  }

  // ---- ticker -------------------------------------------------------------

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _tick() {
    if (status != TimerStatus.running) return;
    if (!DateTime.now().isBefore(_endAt!)) {
      _onPhaseEnd();
    } else {
      notifyListeners();
    }
  }

  // ---- notifications & lifecycle -----------------------------------------

  void _scheduleBackgroundNotification() {
    final s = settings.settings;
    if (!s.notifications || status != TimerStatus.running || _endAt == null) {
      return;
    }
    String title;
    String body;
    switch (phase) {
      case TimerPhase.focus:
        final done = completedFocus + 1;
        final isLong = done >= sessionsPerCycle;
        final mins = isLong ? s.longBreakMinutes : s.shortBreakMinutes;
        title = 'Focus session finished';
        body = 'Session $done of $sessionsPerCycle done. '
            'Time for a $mins-minute ${isLong ? 'long ' : ''}break.';
        break;
      case TimerPhase.shortBreak:
      case TimerPhase.longBreak:
        title = 'Break is over';
        body = 'Time to focus again.';
        break;
    }
    _notifications.scheduleAt(
        at: _endAt!, title: title, body: body, vibrate: s.vibration);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _foreground = false;
      _scheduleBackgroundNotification();
    } else if (state == AppLifecycleState.resumed) {
      _foreground = true;
      _notifications.cancel();
      if (status == TimerStatus.running &&
          !DateTime.now().isBefore(_endAt!)) {
        // Ended while we were away: don't auto-start the next phase.
        _foreground = false;
        _onPhaseEnd();
        _foreground = true;
      } else {
        notifyListeners();
      }
    }
  }

  void _onSettingsChanged() {
    // Apply new durations right away only if the current phase hasn't started.
    if (status == TimerStatus.idle) {
      _resetPhaseTime();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    settings.removeListener(_onSettingsChanged);
    _stopTicker();
    _notifications.cancel();
    _player.dispose();
    super.dispose();
  }
}
