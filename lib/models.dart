import 'package:cloud_firestore/cloud_firestore.dart';

class PomiSettings {
  final int focus, shortBreak, longBreak, longAfter;
  final double volume;
  final bool vibration, notifications;
  const PomiSettings({this.focus = 25, this.shortBreak = 5, this.longBreak = 15, this.longAfter = 4, this.volume = 0.7, this.vibration = true, this.notifications = true});

  PomiSettings copy({int? focus, int? shortBreak, int? longBreak, int? longAfter, double? volume, bool? vibration, bool? notifications}) => PomiSettings(
      focus: focus ?? this.focus, shortBreak: shortBreak ?? this.shortBreak, longBreak: longBreak ?? this.longBreak,
      longAfter: longAfter ?? this.longAfter, volume: volume ?? this.volume, vibration: vibration ?? this.vibration,
      notifications: notifications ?? this.notifications);

  Map<String, dynamic> toMap() => {'focus': focus, 'shortBreak': shortBreak, 'longBreak': longBreak, 'longAfter': longAfter, 'volume': volume, 'vibration': vibration, 'notifications': notifications};

  factory PomiSettings.fromMap(Map<String, dynamic>? m) {
    const d = PomiSettings();
    if (m == null) return d;
    return PomiSettings(
        focus: m['focus'] ?? d.focus, shortBreak: m['shortBreak'] ?? d.shortBreak, longBreak: m['longBreak'] ?? d.longBreak,
        longAfter: m['longAfter'] ?? d.longAfter, volume: (m['volume'] ?? d.volume).toDouble(),
        vibration: m['vibration'] ?? d.vibration, notifications: m['notifications'] ?? d.notifications);
  }
}

class Task {
  final String id, title, notes;
  final bool done;
  Task(this.id, this.title, this.notes, this.done);
  factory Task.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return Task(d.id, m['title'] ?? '', m['notes'] ?? '', m['done'] ?? false);
  }
}

class StudySession {
  final String id;
  final String? taskId, taskTitle;
  final int minutes;
  final DateTime at;
  StudySession(this.id, this.taskId, this.taskTitle, this.minutes, this.at);
  factory StudySession.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return StudySession(d.id, m['taskId'], m['taskTitle'], m['minutes'] ?? 0, (m['at'] as Timestamp?)?.toDate() ?? DateTime.now());
  }
}
