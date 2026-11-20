import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data.dart';
import '../timer_controller.dart';
import 'settings.dart';
import 'stats.dart';
import 'tasks.dart';
import 'timer.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int i = 0;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<DataStore>().settings;
    final key = (s.focus, s.shortBreak, s.longBreak, s.longAfter);
    if (_lastKey != key) {
      _lastKey = key;
      WidgetsBinding.instance.addPostFrameCallback((_) => context.read<TimerController>().settingsChanged());
    }
    const pages = [TimerScreen(), TasksScreen(), StatsScreen(), SettingsScreen()];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: i, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: i,
        onDestinationSelected: (v) => setState(() => i = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.timer_outlined), label: 'Timer'),
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.tune), label: 'PomiSettings'),
        ],
      ),
    );
  }

  (int, int, int, int)? _lastKey;
}
