import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/tasks_provider.dart';
import '../providers/timer_controller.dart';
import '../theme.dart';
import 'task_edit_screen.dart';

/// S7
Future<void> showTaskChooser(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (_) => const _ChooserBody(),
  );
}

class _ChooserBody extends StatefulWidget {
  const _ChooserBody();

  @override
  State<_ChooserBody> createState() => _ChooserBodyState();
}

class _ChooserBodyState extends State<_ChooserBody> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = context.read<TimerController>().selectedTask?.id;
  }

  Future<void> _newTask() async {
    final id = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => const TaskEditScreen()));
    if (id != null && mounted) setState(() => _selected = id);
  }

  @override
  Widget build(BuildContext context) {
    final todo = context.watch<TasksProvider>().todo;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose a task',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: kInk)),
            const SizedBox(height: 4),
            const Text('Time from this session will count toward it.',
                style: TextStyle(color: kMuted, fontSize: 13)),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final t in todo)
                    RadioListTile<String?>(
                      contentPadding: EdgeInsets.zero,
                      value: t.id,
                      groupValue: _selected,
                      onChanged: (v) => setState(() => _selected = v),
                      title: Text(t.title),
                      activeColor: kInk,
                    ),
                  RadioListTile<String?>(
                    contentPadding: EdgeInsets.zero,
                    value: null,
                    groupValue: _selected,
                    onChanged: (v) => setState(() => _selected = v),
                    title: const Text('No task',
                        style: TextStyle(color: kMuted)),
                    activeColor: kInk,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.add),
                    title: const Text('New task',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    onTap: _newTask,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () {
                context.read<TimerController>().selectTask(_selected);
                Navigator.of(context).pop();
              },
              child: const Text('Use this task'),
            ),
          ],
        ),
      ),
    );
  }
}
