import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'models.dart';

/// Holds the logged-in user's settings, tasks and sessions (Firestore).
class DataStore extends ChangeNotifier {
  final String uid;
  PomiSettings settings = const PomiSettings();
  List<Task> tasks = [];
  List<StudySession> sessions = [];
  final _subs = <StreamSubscription>[];

  DataStore(this.uid) {
    final u = _user;
    _subs.add(u.snapshots().listen((s) { settings = PomiSettings.fromMap(s.data()?['settings']); notifyListeners(); }));
    _subs.add(u.collection('tasks').snapshots().listen((s) {
      tasks = s.docs.map(Task.fromDoc).toList()..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      notifyListeners();
    }));
    _subs.add(u.collection('sessions').orderBy('at', descending: true).snapshots().listen((s) {
      sessions = s.docs.map(StudySession.fromDoc).toList();
      notifyListeners();
    }));
  }

  DocumentReference<Map<String, dynamic>> get _user => FirebaseFirestore.instance.collection('users').doc(uid);

  Future<void> saveProfile(String name, String email) => _user.set({'name': name, 'email': email}, SetOptions(merge: true));
  Future<void> saveSettings(PomiSettings s) => _user.set({'settings': s.toMap()}, SetOptions(merge: true));
  Future<void> saveTask({String? id, required String title, required String notes, required bool done}) =>
      (id == null ? _user.collection('tasks').doc() : _user.collection('tasks').doc(id)).set({'title': title, 'notes': notes, 'done': done});
  Future<void> setDone(Task t, bool v) => _user.collection('tasks').doc(t.id).update({'done': v});
  Future<void> deleteTask(String id) => _user.collection('tasks').doc(id).delete();
  Future<void> addSession(int minutes, Task? t) =>
      _user.collection('sessions').add({'minutes': minutes, 'taskId': t?.id, 'taskTitle': t?.title, 'at': Timestamp.now()});

  List<StudySession> forTask(String id) => sessions.where((s) => s.taskId == id).toList();

  @override
  void dispose() {
    for (final s in _subs) { s.cancel(); }
    super.dispose();
  }
}

String get userEmail => FirebaseAuth.instance.currentUser?.email ?? '';
String get userName => FirebaseAuth.instance.currentUser?.displayName ?? '';
