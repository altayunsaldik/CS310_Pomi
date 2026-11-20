import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/sessions_provider.dart';
import '../providers/tasks_provider.dart';
import '../providers/timer_controller.dart';
import '../theme.dart';
import '../utils/format.dart';
import 'task_edit_screen.dart';

/// S9
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _showDone = false;

  void _open(Task? t) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => TaskEditScreen(task: t)));

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TasksProvider>();
    final sessions = context.watch<SessionsProvider>();
    final timer = context.watch<TimerController>();
    final list = _showDone ? tasks.done : tasks.todo;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tasks',
                  style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w800, color: kInk)),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                        value: false,
                        label: Text('To do ${tasks.todo.length}')),
                    ButtonSegment(
                        value: true, label: Text('Done ${tasks.done.length}')),
                  ],
                  selected: {_showDone},
                  onSelectionChanged: (s) =>
                      setState(() => _showDone = s.first),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Text(
                            _showDone
                                ? 'No finished tasks yet.'
                                : 'No tasks. Tap "Add task" to create one.',
                            style: const TextStyle(color: kMuted)))
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 90),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, i) {
                          final t = list[i];
                          return Dismissible(
                            key: ValueKey(t.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red.shade400,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete_outline,
                                  color: Colors.white),
                            ),
                            onDismissed: (_) {
                              tasks.delete(t.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Task deleted')));
                            },
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              onTap: () => _open(t),
                              leading: Checkbox(
                                shape: const CircleBorder(),
                                value: t.done,
                                activeColor: kInk,
                                onChanged: (v) => tasks.setDone(t, v ?? false),
                              ),
                              title: Text(t.title,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      decoration: t.done
                                          ? TextDecoration.lineThrough
                                          : null)),
                              subtitle: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                        sessionsAndTime(
                                            sessions.sessionCountForTask(t.id),
                                            sessions.minutesForTask(t.id)),
                                        style: const TextStyle(fontSize: 12)),
                                  ),
                                  if (timer.selectedTask?.id == t.id) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 1),
                                      decoration: BoxDecoration(
                                          border: Border.all(color: kInk),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: const Text('On timer',
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 20,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: () => _open(null),
            backgroundColor: kInk,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Add task'),
          ),
        ),
      ],
    );
  }
}
