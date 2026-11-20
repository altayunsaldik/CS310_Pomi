import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../services/auth_service.dart';
import '../theme.dart';

/// S12
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SettingsProvider>();
    final s = sp.settings;
    final user = FirebaseAuth.instance.currentUser;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        const Text('Settings',
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.w800, color: kInk)),
        const _Section('Timer'),
        _Stepper(
          label: 'Focus',
          value: '${s.focusMinutes} min',
          onMinus: s.focusMinutes > 5
              ? () => sp.update(s.copyWith(focusMinutes: s.focusMinutes - 5))
              : null,
          onPlus: s.focusMinutes < 90
              ? () => sp.update(s.copyWith(focusMinutes: s.focusMinutes + 5))
              : null,
        ),
        _Stepper(
          label: 'Short break',
          value: '${s.shortBreakMinutes} min',
          onMinus: s.shortBreakMinutes > 1
              ? () => sp
                  .update(s.copyWith(shortBreakMinutes: s.shortBreakMinutes - 1))
              : null,
          onPlus: s.shortBreakMinutes < 30
              ? () => sp
                  .update(s.copyWith(shortBreakMinutes: s.shortBreakMinutes + 1))
              : null,
        ),
        _Stepper(
          label: 'Long break',
          value: '${s.longBreakMinutes} min',
          onMinus: s.longBreakMinutes > 5
              ? () => sp
                  .update(s.copyWith(longBreakMinutes: s.longBreakMinutes - 5))
              : null,
          onPlus: s.longBreakMinutes < 60
              ? () => sp
                  .update(s.copyWith(longBreakMinutes: s.longBreakMinutes + 5))
              : null,
        ),
        _Stepper(
          label: 'Long break after',
          value: '${s.sessionsBeforeLongBreak} sessions',
          onMinus: s.sessionsBeforeLongBreak > 2
              ? () => sp.update(s.copyWith(
                  sessionsBeforeLongBreak: s.sessionsBeforeLongBreak - 1))
              : null,
          onPlus: s.sessionsBeforeLongBreak < 8
              ? () => sp.update(s.copyWith(
                  sessionsBeforeLongBreak: s.sessionsBeforeLongBreak + 1))
              : null,
        ),
        const _Section('Sound and alerts'),
        Row(
          children: [
            const Text('Volume'),
            const SizedBox(width: 12),
            const Icon(Icons.volume_up_outlined, size: 18, color: kMuted),
            Expanded(
              child: Slider(
                value: s.volume,
                activeColor: kInk,
                onChanged: (v) => sp.preview(s.copyWith(volume: v)),
                onChangeEnd: (_) => sp.commit(),
              ),
            ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Vibration'),
          value: s.vibration,
          activeColor: kInk,
          onChanged: (v) => sp.update(s.copyWith(vibration: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Notifications'),
          value: s.notifications,
          activeColor: kInk,
          onChanged: (v) => sp.update(s.copyWith(notifications: v)),
        ),
        const _Section('Account'),
        Text(
          (user?.displayName?.isNotEmpty ?? false) ? user!.displayName! : 'Account',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(user?.email ?? '',
            style: const TextStyle(color: kMuted, fontSize: 13)),
        const SizedBox(height: 8),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.logout),
          title: const Text('Log out',
              style: TextStyle(fontWeight: FontWeight.w700)),
          onTap: () => AuthService.instance.signOut(),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 6),
        child: Text(title,
            style: const TextStyle(
                fontSize: 12, color: kMuted, fontWeight: FontWeight.w700)),
      );
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final String label, value;
  final VoidCallback? onMinus, onPlus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          IconButton.outlined(
              onPressed: onMinus, icon: const Icon(Icons.remove, size: 18)),
          SizedBox(
            width: 96,
            child: Text(value,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          IconButton.outlined(
              onPressed: onPlus, icon: const Icon(Icons.add, size: 18)),
        ],
      ),
    );
  }
}
