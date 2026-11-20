import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/study_session.dart';
import '../services/firestore_service.dart';

class SessionsProvider extends ChangeNotifier {
  SessionsProvider(this._fs) {
    _sub = _fs.watchSessions().listen((s) {
      _sessions = s;
      notifyListeners();
    }, onError: (_) {});
  }

  final FirestoreService _fs;
  late final StreamSubscription<List<StudySession>> _sub;
  List<StudySession> _sessions = [];

  /// Newest first.
  List<StudySession> get sessions => _sessions;

  void add(StudySession s) {
    _fs.addSession(s).catchError((_) {});
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime weekStart(DateTime now) {
    final d = DateTime(now.year, now.month, now.day);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  List<StudySession> get today {
    final now = DateTime.now();
    return _sessions.where((s) => _sameDay(s.startedAt, now)).toList();
  }

  List<StudySession> get thisWeek {
    final start = weekStart(DateTime.now());
    final end = start.add(const Duration(days: 7));
    return _sessions
        .where((s) => !s.startedAt.isBefore(start) && s.startedAt.isBefore(end))
        .toList();
  }

  static int totalMinutes(Iterable<StudySession> list) =>
      (list.fold<int>(0, (a, s) => a + s.durationSeconds) / 60).round();

  int get todayMinutes => totalMinutes(today);
  int get weekMinutes => totalMinutes(thisWeek);

  /// Minutes studied for Monday..Sunday of the current week.
  List<int> get weekMinutesPerDay {
    final start = weekStart(DateTime.now());
    return List.generate(7, (i) {
      final day = start.add(Duration(days: i));
      return totalMinutes(_sessions.where((s) => _sameDay(s.startedAt, day)));
    });
  }

  int sessionCountForTask(String id) =>
      _sessions.where((s) => s.taskId == id).length;

  int minutesForTask(String id) =>
      totalMinutes(_sessions.where((s) => s.taskId == id));

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
