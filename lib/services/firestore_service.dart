import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_settings.dart';
import '../models/study_session.dart';
import '../models/task.dart';

/// Data layout:
///   users/{uid}                 -> profile + `settings` map
///   users/{uid}/tasks/{id}      -> tasks
///   users/{uid}/sessions/{id}   -> finished focus sessions
class FirestoreService {
  FirestoreService(this.uid, [FirebaseFirestore? db])
      : _db = db ?? FirebaseFirestore.instance;

  final String uid;
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> get _user =>
      _db.collection('users').doc(uid);
  CollectionReference<Map<String, dynamic>> get _tasks =>
      _user.collection('tasks');
  CollectionReference<Map<String, dynamic>> get _sessions =>
      _user.collection('sessions');

  static Future<void> createProfile(String uid, String name, String email) =>
      FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'createdAt': Timestamp.now(),
      }, SetOptions(merge: true));

  // Tasks
  Stream<List<Task>> watchTasks() => _tasks
      .orderBy('createdAt')
      .snapshots()
      .map((s) => s.docs.map(Task.fromDoc).toList());

  String newTaskId() => _tasks.doc().id;

  Future<void> saveTask(Task t) => _tasks.doc(t.id).set(t.toMap());

  Future<void> deleteTask(String id) => _tasks.doc(id).delete();

  // Sessions
  Stream<List<StudySession>> watchSessions() => _sessions
      .orderBy('startedAt', descending: true)
      .limit(500)
      .snapshots()
      .map((s) => s.docs.map(StudySession.fromDoc).toList());

  Future<void> addSession(StudySession s) => _sessions.add(s.toMap());

  // Settings
  Stream<AppSettings> watchSettings() => _user.snapshots().map((d) =>
      AppSettings.fromMap(d.data()?['settings'] as Map<String, dynamic>?));

  Future<void> saveSettings(AppSettings s) =>
      _user.set({'settings': s.toMap()}, SetOptions(merge: true));
}
