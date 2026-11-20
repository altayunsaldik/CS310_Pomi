import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/app_logo.dart';

/// S1
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Spacer(flex: 3),
            AppLogo(size: 84),
            SizedBox(height: 16),
            Text('Pomodoro',
                style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w800, color: kInk)),
            SizedBox(height: 4),
            Text('Study timer and task list',
                style: TextStyle(fontSize: 13, color: kMuted)),
            Spacer(flex: 2),
            SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 3, color: kInk)),
            SizedBox(height: 56),
          ],
        ),
      ),
    );
  }
}
