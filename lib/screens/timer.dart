import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data.dart';
import '../models.dart';
import '../timer_controller.dart';
import 'tasks.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<TimerController>();
    final s = t.s;
    final rem = t.remaining < Duration.zero ? Duration.zero : t.remaining;
    final mm = rem.inMinutes.toString().padLeft(2, '0'), ss = (rem.inSeconds % 60).toString().padLeft(2, '0');
    final focus = t.phase == Phase.focus;
    final done = t.focusDone % s.longAfter;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(children: [
        const SizedBox(height: 24),
        Text(t.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (var i = 0; i < s.longAfter; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Icon(i < done ? Icons.circle : (i == done && focus ? Icons.contrast : Icons.circle_outlined), size: 12, color: cs.primary),
            ),
          const SizedBox(width: 8),
          Text(focus ? 'Session ${done + 1} of ${s.longAfter}' : '$done of ${s.longAfter} done'),
        ]),
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: CustomPaint(
                painter: _Ring(t.progress, cs.primary, cs.surfaceContainerHighest),
                child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('$mm:$ss', style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w300)),
                    Text('of ${t.total.inMinutes.toString().padLeft(2, '0')}:00'),
                    if (!t.running && !t.untouchedNow) Chip(label: const Text('Paused'), visualDensity: VisualDensity.compact),
                  ]),
                ),
              ),
            ),
          ),
        ),
        _TaskCard(focus: focus, t: t),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _Btn(Icons.replay, 'Reset', t.reset),
          _Btn(t.running ? Icons.pause : Icons.play_arrow, t.running ? 'Pause' : (t.untouchedNow ? 'Start' : 'Resume'), t.toggle, big: true),
          _Btn(Icons.skip_next, 'Skip', t.skip),
        ]),
        const SizedBox(height: 20),
      ]),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final bool focus;
  final TimerController t;
  const _TaskCard({required this.focus, required this.t});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(focus ? 'Task for this session' : 'Up next: session ${t.focusDone % t.s.longAfter + 1} of ${t.s.longAfter}', style: const TextStyle(fontSize: 12)),
              Text(t.task?.title ?? 'No task', style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            ]),
          ),
          TextButton(onPressed: () => chooseTask(context), child: const Text('Change')),
        ]),
      );
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool big;
  const _Btn(this.icon, this.label, this.onTap, {this.big = false});
  @override
  Widget build(BuildContext context) {
    final d = big ? 72.0 : 52.0;
    return Column(children: [
      big
          ? SizedBox(width: d, height: d, child: IconButton.filled(onPressed: onTap, icon: Icon(icon, size: 34)))
          : SizedBox(width: d, height: d, child: IconButton.outlined(onPressed: onTap, icon: Icon(icon))),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 12)),
    ]);
  }
}

class _Ring extends CustomPainter {
  final double p;
  final Color fg, bg;
  _Ring(this.p, this.fg, this.bg);
  @override
  void paint(Canvas c, Size s) {
    final r = s.width / 2 - 8;
    final o = Offset(s.width / 2, s.height / 2);
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 10..strokeCap = StrokeCap.round;
    c.drawCircle(o, r, paint..color = bg);
    c.drawArc(Rect.fromCircle(center: o, radius: r), -pi / 2, 2 * pi * p, false, paint..color = fg);
  }

  @override
  bool shouldRepaint(_Ring o) => o.p != p || o.fg != fg;
}

/// S7: bottom sheet to pick the task for the session.
Future<void> chooseTask(BuildContext context) async {
  final t = context.read<TimerController>();
  Task? sel = t.task;
  await showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => StatefulBuilder(builder: (ctx, set) {
      final tasks = context.read<DataStore>().tasks.where((x) => !x.done).toList();
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Choose a task', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text('Time from this session will count toward it.'),
          Flexible(
            child: ListView(shrinkWrap: true, children: [
              RadioGroup<String?>(
                groupValue: sel?.id,
                onChanged: (v) => set(() => sel = tasks.where((x) => x.id == v).firstOrNull),
                child: Column(children: [
                  for (final x in tasks) RadioListTile<String?>(value: x.id, title: Text(x.title)),
                  const RadioListTile<String?>(value: null, title: Text('No task')),
                ]),
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('New task'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const TaskForm()));
                },
              ),
            ]),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            onPressed: () { t.selectTask(sel); Navigator.pop(ctx); },
            child: const Text('Use this task'),
          ),
        ]),
      );
    }),
  );
}
