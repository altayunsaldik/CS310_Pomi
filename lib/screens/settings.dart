import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final d = context.watch<DataStore>();
    final s = d.settings;
    Widget sec(String t) => Padding(padding: const EdgeInsets.only(top: 18, bottom: 4), child: Text(t, style: const TextStyle(color: Colors.grey)));
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('PomiSettings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      sec('Timer'),
      _Step('Focus', '${s.focus} min', s.focus, 1, 90, (v) => d.saveSettings(s.copy(focus: v))),
      _Step('Short break', '${s.shortBreak} min', s.shortBreak, 1, 30, (v) => d.saveSettings(s.copy(shortBreak: v))),
      _Step('Long break', '${s.longBreak} min', s.longBreak, 1, 60, (v) => d.saveSettings(s.copy(longBreak: v))),
      _Step('Long break after', '${s.longAfter} sessions', s.longAfter, 2, 10, (v) => d.saveSettings(s.copy(longAfter: v))),
      sec('Sound and alerts'),
      Row(children: [
        const Text('Volume'),
        Expanded(child: Slider(value: s.volume, onChanged: (v) => d.saveSettings(s.copy(volume: v)))),
      ]),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Vibration'), value: s.vibration, onChanged: (v) => d.saveSettings(s.copy(vibration: v))),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Notifications'), value: s.notifications, onChanged: (v) => d.saveSettings(s.copy(notifications: v))),
      sec('Account'),
      Text(userName.isEmpty ? 'Account' : userName, style: const TextStyle(fontWeight: FontWeight.bold)),
      Text(userEmail),
      TextButton.icon(
        style: TextButton.styleFrom(alignment: Alignment.centerLeft, padding: EdgeInsets.zero),
        onPressed: () => FirebaseAuth.instance.signOut(),
        icon: const Icon(Icons.logout),
        label: const Text('Log out'),
      ),
    ]);
  }
}

class _Step extends StatelessWidget {
  final String label, value;
  final int v, min, max;
  final ValueChanged<int> on;
  const _Step(this.label, this.value, this.v, this.min, this.max, this.on);
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Text(label)),
        IconButton.outlined(onPressed: v > min ? () => on(v - 1) : null, icon: const Icon(Icons.remove)),
        SizedBox(width: 100, child: Text(value, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
        IconButton.outlined(onPressed: v < max ? () => on(v + 1) : null, icon: const Icon(Icons.add)),
      ]);
}
