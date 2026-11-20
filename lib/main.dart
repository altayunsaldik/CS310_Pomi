import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data.dart';
import 'notifications.dart';
import 'screens/auth.dart';
import 'screens/home.dart';
import 'timer_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Notifier.init();
  runApp(const PomiApp());
}

class PomiApp extends StatelessWidget {
  const PomiApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Pomi',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE5533D)),
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const AuthGate(),
      );
}

/// Splash (S1) while checking auth, then Timer if logged in, otherwise Log in.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (c, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Splash();
          final u = snap.data;
          if (u == null) return const LoginScreen();
          return MultiProvider(
            key: ValueKey(u.uid),
            providers: [
              ChangeNotifierProvider(create: (_) => DataStore(u.uid)),
              ChangeNotifierProvider(create: (c) => TimerController(c.read<DataStore>())),
            ],
            child: const Home(),
          );
        },
      );
}
