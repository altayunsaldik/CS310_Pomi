String formatMinutes(int m) {
  if (m < 60) return '$m min';
  final h = m ~/ 60;
  final r = m % 60;
  return r == 0 ? '$h h' : '$h h $r min';
}

String formatClock(int totalSeconds) {
  final m = totalSeconds ~/ 60;
  final s = totalSeconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

String formatTime(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

String sessionsAndTime(int sessions, int minutes) {
  if (sessions == 0) return 'No sessions yet';
  final s = sessions == 1 ? '1 session' : '$sessions sessions';
  return '$s, ${formatMinutes(minutes)}';
}
