import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/sessions_provider.dart';
import '../providers/tasks_provider.dart';
import '../theme.dart';
import '../utils/format.dart';

/// S10. Pops with the id of the saved task.
class TaskEditScreen extends StatefulWidget {
  const TaskEditScreen({super.key, this.task});
  final Task? task;

  @override
  State<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  late final TextEditingController _title =
      TextEditingController(text: widget.task?.title ?? '');
  late final TextEditingController _notes =
      TextEditingController(text: widget.task?.notes ?? '');
  late bool _done = widget.task?.done ?? false;
  String? _error;

  bool get _isNew => widget.task == null;

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Title is required.');
      return;
    }
    final tasks = context.read<TasksProvider>();
    final Task task;
    if (_isNew) {
      task = Task(
        id: tasks.newId(),
        title: title,
        notes: _notes.text.trim(),
        done: _done,
        createdAt: DateTime.now(),
      );
    } else {
      task = widget.task!
          .copyWith(title: title, notes: _notes.text.trim(), done: _done);
    }
    tasks.save(task);
    Navigator.of(context).pop(task.id);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete task?'),
        content: const Text('Past sessions stay in your history.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<TasksProvider>().delete(widget.task!.id);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessions = context.watch<SessionsProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop()),
        title: Text(_isNew ? 'New task' : 'Edit task'),
        actions: [
          TextButton(
              onPressed: _save,
              child: const Text('Save',
                  style: TextStyle(fontWeight: FontWeight.w800))),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            children: [
              TextField(
                controller: _title,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                decoration:
                    InputDecoration(labelText: 'Title', errorText: _error),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notes,
                minLines: 4,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    labelText: 'Notes (optional)', alignLabelWithHint: true),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Mark as done'),
                value: _done,
                activeColor: kInk,
                onChanged: (v) => setState(() => _done = v),
              ),
              if (!_isNew)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: kPanel, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Time spent',
                          style: TextStyle(color: kMuted)),
                      Text(
                        sessionsAndTime(
                            sessions.sessionCountForTask(widget.task!.id),
                            sessions.minutesForTask(widget.task!.id)),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              if (!_isNew)
                OutlinedButton.icon(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete task'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: kInk,
                    side: const BorderSide(color: kInk),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
