import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/sessions_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/tasks_provider.dart';
import 'providers/timer_controller.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/notification_service.dart';
import 'theme.dart';

/// Root. Shows the splash (S1) while checking the login state, then the timer
/// (logged in) or the login screen. The per-user providers sit above the
/// MaterialApp so that every pushed route can read them.
class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  Widget _app(Widget home) => MaterialApp(
        title: 'Pomodoro',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: home,
      );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.userChanges,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return _app(const SplashScreen());
        }
        final user = snap.data;
        if (user == null) return _app(const LoginScreen());
        return UserScope(
          key: ValueKey(user.uid),
          user: user,
          child: _app(const HomeShell()),
        );
      },
    );
  }
}

/// Creates the per-user providers (all data is saved under the user's uid).
class UserScope extends StatefulWidget {
  const UserScope({super.key, required this.user, required this.child});
  final User user;
  final Widget child;

  @override
  State<UserScope> createState() => _UserScopeState();
}

class _UserScopeState extends State<UserScope> {
  late final FirestoreService _fs = FirestoreService(widget.user.uid);

  @override
  void initState() {
    super.initState();
    NotificationService.instance.requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirestoreService>.value(value: _fs),
        ChangeNotifierProvider(create: (_) => SettingsProvider(_fs)),
        ChangeNotifierProvider(create: (_) => TasksProvider(_fs)),
        ChangeNotifierProvider(create: (_) => SessionsProvider(_fs)),
        ChangeNotifierProvider(
          create: (c) => TimerController(
            settings: c.read<SettingsProvider>(),
            tasks: c.read<TasksProvider>(),
            sessions: c.read<SessionsProvider>(),
          ),
        ),
      ],
      child: widget.child,
    );
  }
}
