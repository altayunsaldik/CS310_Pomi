import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/study_session.dart';
import '../providers/sessions_provider.dart';
import '../theme.dart';
import '../utils/format.dart';

/// S11
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SessionsProvider>();
    final perDay = s.weekMinutesPerDay;
    final maxV = math.max(1, perDay.fold<int>(0, math.max));
    final todayIdx = DateTime.now().weekday - 1;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        const Text('Stats',
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.w800, color: kInk)),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
                child: _StatCard(
                    label: 'Today',
                    value: formatMinutes(s.todayMinutes),
                    sub: '${s.today.length} sessions')),
            const SizedBox(width: 12),
            Expanded(
                child: _StatCard(
                    label: 'This week',
                    value: formatMinutes(s.weekMinutes),
                    sub: '${s.thisWeek.length} sessions')),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              border: Border.all(color: kLine),
              borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Minutes studied per day',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 10),
              SizedBox(
                height: 130,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < 7; i++)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(perDay[i] > 0 ? '${perDay[i]}' : '',
                                style: const TextStyle(
                                    fontSize: 10, color: kMuted)),
                            const SizedBox(height: 2),
                            Container(
                              width: 22,
                              height: math.max(3, 90 * perDay[i] / maxV),
                              decoration: BoxDecoration(
                                color: perDay[i] == 0
                                    ? kTrack
                                    : (i == todayIdx ? kInk : kLine),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(_days[i],
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: i == todayIdx
                                        ? FontWeight.w800
                                        : FontWeight.w400,
                                    color: kInk)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('History',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: kInk)),
        const SizedBox(height: 6),
        if (s.sessions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
                child: Text('Finish a focus session to see it here.',
                    style: TextStyle(color: kMuted))),
          )
        else
          ..._history(s.sessions),
      ],
    );
  }

  List<Widget> _history(List<StudySession> sessions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final widgets = <Widget>[];
    DateTime? lastDay;
    for (final x in sessions) {
      final d = DateTime(x.startedAt.year, x.startedAt.month, x.startedAt.day);
      if (lastDay != d) {
        lastDay = d;
        final diff = today.difference(d).inDays;
        final label = diff == 0
            ? 'Today'
            : diff == 1
                ? 'Yesterday'
                : '${_months[d.month - 1]} ${d.day}, ${d.year}';
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12, color: kMuted, fontWeight: FontWeight.w700)),
        ));
      }
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
                width: 52,
                child: Text(formatTime(x.startedAt),
                    style: const TextStyle(color: kMuted, fontSize: 13))),
            Expanded(
              child: Text(x.taskTitle ?? 'No task',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 14,
                      color: x.taskTitle == null ? kMuted : kInk)),
            ),
            Text(formatMinutes(x.minutes),
                style: const TextStyle(fontSize: 13)),
          ],
        ),
      ));
      widgets.add(const Divider());
    }
    return widgets;
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.sub});
  final String label, value, sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          border: Border.all(color: kLine),
          borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: kMuted)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: kInk)),
          ),
          Text(sub, style: const TextStyle(fontSize: 12, color: kMuted)),
        ],
      ),
    );
  }
}
