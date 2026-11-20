import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';
import '../services/firestore_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._fs) {
    _sub = _fs.watchSettings().listen((s) {
      _settings = s;
      notifyListeners();
    }, onError: (_) {});
  }

  final FirestoreService _fs;
  late final StreamSubscription<AppSettings> _sub;
  AppSettings _settings = const AppSettings();

  AppSettings get settings => _settings;

  /// Update locally only (used while dragging the volume slider).
  void preview(AppSettings s) {
    _settings = s;
    notifyListeners();
  }

  /// Update locally and save to Firestore.
  void update(AppSettings s) {
    _settings = s;
    notifyListeners();
    _fs.saveSettings(s).catchError((_) {});
  }

  void commit() => update(_settings);

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
