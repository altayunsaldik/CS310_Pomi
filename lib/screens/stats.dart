import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../data.dart';
import '../models.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final all = context.watch<DataStore>().sessions;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: now.weekday - 1));
    int mins(Iterable<StudySession> l) => l.fold(0, (a, s) => a + s.minutes);
    final todayS = all.where((s) => !s.at.isBefore(today)).toList();
    final weekS = all.where((s) => !s.at.isBefore(monday)).toList();
    final perDay = List.generate(7, (i) {
      final d = monday.add(Duration(days: i));
      return mins(weekS.where((s) => s.at.year == d.year && s.at.month == d.month && s.at.day == d.day));
    });
    final maxV = perDay.fold(1, (a, b) => b > a ? b : a);
    final cs = Theme.of(context).colorScheme;

    // History grouped by day
    final groups = <String, List<StudySession>>{};
    for (final s in all) {
      final d = DateTime(s.at.year, s.at.month, s.at.day);
      final label = d == today ? 'Today' : d == today.subtract(const Duration(days: 1)) ? 'Yesterday' : DateFormat('d MMM yyyy').format(d);
      groups.putIfAbsent(label, () => []).add(s);
    }

    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Stats', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _Card('Today', _fmt(mins(todayS)), '${todayS.length} sessions')),
        const SizedBox(width: 12),
        Expanded(child: _Card('This week', _fmt(mins(weekS)), '${weekS.length} sessions')),
      ]),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Minutes studied per day', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 140,
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text(perDay[i] > 0 ? '${perDay[i]}' : '', style: const TextStyle(fontSize: 11)),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      height: perDay[i] == 0 ? 2 : 90.0 * perDay[i] / maxV,
                      decoration: BoxDecoration(color: monday.add(Duration(days: i)) == today ? cs.primary : cs.primary.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(3)),
                    ),
                    const SizedBox(height: 4),
                    Text('MTWTFSS'[i], style: const TextStyle(fontSize: 12)),
                  ]),
                ),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 16),
      const Text('History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      if (all.isEmpty) const Padding(padding: EdgeInsets.only(top: 12), child: Text('No sessions yet. Finish a focus session to see it here.')),
      for (final e in groups.entries) ...[
        Padding(padding: const EdgeInsets.only(top: 12, bottom: 4), child: Text(e.key, style: const TextStyle(color: Colors.grey))),
        for (final s in e.value)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Text(DateFormat('HH:mm').format(s.at)),
            title: Text(s.taskTitle ?? 'No task'),
            trailing: Text('${s.minutes} min'),
          ),
      ],
    ]);
  }
}

String _fmt(int m) => m >= 60 ? '${m ~/ 60} h ${m % 60} min' : '$m min';

class _Card extends StatelessWidget {
  final String a, b, c;
  const _Card(this.a, this.b, this.c);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(a, style: const TextStyle(fontSize: 12)),
          Text(b, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(c, style: const TextStyle(fontSize: 12)),
        ]),
      );
}
