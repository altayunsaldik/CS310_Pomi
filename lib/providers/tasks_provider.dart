import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../services/firestore_service.dart';

class TasksProvider extends ChangeNotifier {
  TasksProvider(this._fs) {
    _sub = _fs.watchTasks().listen((t) {
      _tasks = t;
      notifyListeners();
    }, onError: (_) {});
  }

  final FirestoreService _fs;
  late final StreamSubscription<List<Task>> _sub;
  List<Task> _tasks = [];

  List<Task> get todo => _tasks.where((t) => !t.done).toList();
  List<Task> get done => _tasks.where((t) => t.done).toList();

  Task? byId(String? id) {
    if (id == null) return null;
    for (final t in _tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  String newId() => _fs.newTaskId();

  void save(Task t) {
    _fs.saveTask(t).catchError((_) {});
  }

  void setDone(Task t, bool value) => save(t.copyWith(done: value));

  void delete(String id) {
    _fs.deleteTask(id).catchError((_) {});
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
