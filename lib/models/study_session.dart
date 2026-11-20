import 'package:cloud_firestore/cloud_firestore.dart';

class StudySession {
  final String id;
  final String? taskId;
  final String? taskTitle;
  final DateTime startedAt;
  final int durationSeconds;

  const StudySession({
    required this.id,
    this.taskId,
    this.taskTitle,
    required this.startedAt,
    required this.durationSeconds,
  });

  int get minutes => (durationSeconds / 60).round();

  factory StudySession.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return StudySession(
      id: doc.id,
      taskId: d['taskId'] as String?,
      taskTitle: d['taskTitle'] as String?,
      startedAt: (d['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      durationSeconds: (d['durationSeconds'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'taskId': taskId,
        'taskTitle': taskTitle,
        'startedAt': Timestamp.fromDate(startedAt),
        'durationSeconds': durationSeconds,
      };
}
