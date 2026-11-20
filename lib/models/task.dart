import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String notes;
  final bool done;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    this.notes = '',
    this.done = false,
    required this.createdAt,
  });

  Task copyWith({String? title, String? notes, bool? done}) => Task(
        id: id,
        title: title ?? this.title,
        notes: notes ?? this.notes,
        done: done ?? this.done,
        createdAt: createdAt,
      );

  factory Task.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Task(
      id: doc.id,
      title: (d['title'] as String?) ?? '',
      notes: (d['notes'] as String?) ?? '',
      done: (d['done'] as bool?) ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'notes': notes,
        'done': done,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
