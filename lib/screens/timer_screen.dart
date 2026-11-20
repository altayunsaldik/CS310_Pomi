import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/timer_controller.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/session_dots.dart';
import '../widgets/timer_ring.dart';
import 'task_chooser_sheet.dart';

/// S5 (focus) and S6 (break).
class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<TimerController>();
    final isFocus = t.phase == TimerPhase.focus;
    final n = t.sessionsPerCycle;

    final dots = List.generate(n, (i) {
      if (i < t.completedFocus) return DotState.full;
      if (isFocus && i == t.completedFocus) return DotState.half;
      return DotState.empty;
    });
    final sub = isFocus
        ? 'Session ${t.completedFocus + 1} of $n'
        : '${t.completedFocus} of $n done';

    final running = t.status == TimerStatus.running;
    final String mainLabel = running
        ? 'Pause'
        : t.status == TimerStatus.paused
            ? 'Resume'
            : 'Start';

    return LayoutBuilder(builder: (context, c) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(t.phaseTitle,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w800, color: kInk)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SessionDots(states: dots),
                    const SizedBox(width: 8),
                    Text(sub,
                        style: const TextStyle(fontSize: 13, color: kMuted)),
                  ],
                ),
                const SizedBox(height: 24),
                TimerRing(
                  fraction: t.fraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(formatClock(t.remainingSeconds),
                          style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w300,
                              color: kInk,
                              fontFeatures: [FontFeature.tabularFigures()])),
                      Text('of ${formatClock(t.totalSeconds)}',
                          style: const TextStyle(fontSize: 13, color: kMuted)),
                      if (t.status == TimerStatus.paused) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                              border: Border.all(color: kInk),
                              borderRadius: BorderRadius.circular(12)),
                          child: const Text('Paused',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _TaskCard(timer: t),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RoundButton(
                        icon: Icons.refresh, label: 'Reset', onTap: t.reset),
                    const SizedBox(width: 28),
                    _RoundButton(
                      icon: running ? Icons.pause : Icons.play_arrow,
                      label: mainLabel,
                      onTap: t.startOrPause,
                      big: true,
                    ),
                    const SizedBox(width: 28),
                    _RoundButton(
                        icon: Icons.skip_next, label: 'Skip', onTap: t.skip),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.timer});
  final TimerController timer;

  @override
  Widget build(BuildContext context) {
    final isFocus = timer.phase == TimerPhase.focus;
    final title = timer.selectedTask?.title ?? 'No task';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        border: Border.all(color: kLine),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFocus
                      ? 'Task for this session'
                      : 'Up next: session ${timer.upNextSession} of ${timer.sessionsPerCycle}',
                  style: const TextStyle(fontSize: 12, color: kMuted),
                ),
                const SizedBox(height: 2),
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700, color: kInk)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => showTaskChooser(context),
            child: const Text('Change',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline)),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.big = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final size = big ? 68.0 : 50.0;
    return Column(
      children: [
        Material(
          color: big ? kInk : Colors.white,
          shape: CircleBorder(side: BorderSide(color: big ? kInk : kInk)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(icon, color: big ? Colors.white : kInk, size: big ? 32 : 24),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: kInk)),
      ],
    );
  }
}
