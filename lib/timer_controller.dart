import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data.dart';
import 'models.dart';
import 'notifications.dart';

enum Phase { focus, shortBreak, longBreak }

/// Pomodoro state machine. Uses an absolute end time so it stays correct in the background.
class TimerController extends ChangeNotifier with WidgetsBindingObserver {
  final DataStore data;
  Phase phase = Phase.focus;
  int focusDone = 0; // focus sessions finished in the current cycle
  bool running = false;
  Task? task;
  DateTime? _end;
  Duration _left;
  Timer? _tick;
  final _player = AudioPlayer();

  TimerController(this.data) : _left = Duration(minutes: data.settings.focus) {
    WidgetsBinding.instance.addObserver(this);
  }

  PomiSettings get s => data.settings;
  Duration get total => Duration(minutes: phase == Phase.focus ? s.focus : phase == Phase.shortBreak ? s.shortBreak : s.longBreak);
  Duration get remaining => running ? _end!.difference(DateTime.now()) : _left;
  double get progress => total.inSeconds == 0 ? 0 : (remaining.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
  String get title => phase == Phase.focus ? 'Focus' : phase == Phase.shortBreak ? 'Short break' : 'Long break';

  bool _isFresh = true;
  bool get untouchedNow => !running && _isFresh;

  /// Re-reads durations when settings change and the current phase has not been started.
  void settingsChanged() {
    if (!running && _isFresh) { _left = total; notifyListeners(); }
  }

  void selectTask(Task? t) { task = t; notifyListeners(); }

  void toggle() => running ? pause() : start();

  void start() {
    _isFresh = false;
    if (_left.inSeconds <= 0) _left = total;
    _end = DateTime.now().add(_left);
    running = true;
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(milliseconds: 250), (_) => _check());
    if (s.notifications) Notifier.schedule(_end!, _notifTitle, _notifBody);
    notifyListeners();
  }

  void pause() {
    _left = remaining;
    running = false;
    _tick?.cancel();
    Notifier.cancel();
    notifyListeners();
  }

  void reset() {
    running = false;
    _tick?.cancel();
    Notifier.cancel();
    _left = total;
    _isFresh = true;
    notifyListeners();
  }

  void skip() {
    running = false;
    _tick?.cancel();
    Notifier.cancel();
    _advance(false);
  }

  void _check() {
    if (remaining <= Duration.zero) {
      running = false;
      _tick?.cancel();
      _alert();
      _advance(true);
    } else {
      notifyListeners();
    }
  }

  void _advance(bool completed) {
    if (phase == Phase.focus) {
      if (completed) data.addSession(s.focus, task);
      focusDone++;
      phase = focusDone % s.longAfter == 0 ? Phase.longBreak : Phase.shortBreak;
    } else {
      if (phase == Phase.longBreak) focusDone = 0;
      phase = Phase.focus;
    }
    _left = total;
    _isFresh = true;
    notifyListeners();
  }

  String get _notifTitle => phase == Phase.focus ? 'Focus session finished' : 'Break is over';
  String get _notifBody {
    if (phase == Phase.focus) {
      final n = (focusDone + 1);
      final next = n % s.longAfter == 0 ? '${s.longBreak}-minute long break' : '${s.shortBreak}-minute break';
      return 'Session $n of ${s.longAfter} done. Time for a $next.';
    }
    return 'Time to focus again.';
  }

  Future<void> _alert() async {
    if (s.vibration) { HapticFeedback.vibrate(); }
    if (s.volume > 0) {
      await _player.setVolume(s.volume);
      await _player.play(AssetSource('ding.wav'));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && running) _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tick?.cancel();
    _player.dispose();
    super.dispose();
  }
}
