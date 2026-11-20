import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data.dart';
import '../models.dart';
import '../timer_controller.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  @override
  State<TasksScreen> createState() => _TasksState();
}

class _TasksState extends State<TasksScreen> {
  bool done = false;

  @override
  Widget build(BuildContext context) {
    final d = context.watch<DataStore>();
    final cur = context.watch<TimerController>().task?.id;
    final todo = d.tasks.where((t) => !t.done).toList(), fin = d.tasks.where((t) => t.done).toList();
    final list = done ? fin : todo;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TaskForm())),
        icon: const Icon(Icons.add),
        label: const Text('Add task'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 20),
          const Text('Tasks', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<bool>(
              segments: [ButtonSegment(value: false, label: Text('To do ${todo.length}')), ButtonSegment(value: true, label: Text('Done ${fin.length}'))],
              selected: {done},
              onSelectionChanged: (v) => setState(() => done = v.first),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? Center(child: Text(done ? 'No finished tasks.' : 'No tasks yet. Add one!'))
                : ListView(children: [
                    for (final t in list)
                      Dismissible(
                        key: ValueKey(t.id),
                        direction: DismissDirection.endToStart,
                        background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                        onDismissed: (_) => d.deleteTask(t.id),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Checkbox(shape: const CircleBorder(), value: t.done, onChanged: (v) => d.setDone(t, v ?? false)),
                          title: Text(t.title, style: TextStyle(fontWeight: FontWeight.bold, decoration: t.done ? TextDecoration.lineThrough : null)),
                          subtitle: Row(children: [
                            Text(_spent(d.forTask(t.id))),
                            if (cur == t.id) ...[const SizedBox(width: 8), const Chip(label: Text('On timer'), visualDensity: VisualDensity.compact)],
                          ]),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskForm(task: t))),
                        ),
                      ),
                  ]),
          ),
        ]),
      ),
    );
  }
}

String _spent(List<StudySession> s) {
  if (s.isEmpty) return 'No sessions yet';
  final m = s.fold<int>(0, (a, x) => a + x.minutes);
  return '${s.length} session${s.length == 1 ? '' : 's'}, $m min';
}

/// S10: add or edit a task.
class TaskForm extends StatefulWidget {
  final Task? task;
  const TaskForm({super.key, this.task});
  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  late final title = TextEditingController(text: widget.task?.title);
  late final notes = TextEditingController(text: widget.task?.notes);
  late bool done = widget.task?.done ?? false;
  String? err;

  @override
  Widget build(BuildContext context) {
    final d = context.read<DataStore>();
    final t = widget.task;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        title: Text(t == null ? 'New task' : 'Edit task'),
        actions: [
          TextButton(
            onPressed: () {
              if (title.text.trim().isEmpty) { setState(() => err = 'Title is required.'); return; }
              d.saveTask(id: t?.id, title: title.text.trim(), notes: notes.text.trim(), done: done);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        TextField(controller: title, decoration: InputDecoration(labelText: 'Title', errorText: err, border: const OutlineInputBorder())),
        const SizedBox(height: 16),
        TextField(controller: notes, maxLines: 4, decoration: const InputDecoration(labelText: 'Notes (optional)', alignLabelWithHint: true, border: OutlineInputBorder())),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Mark as done'), value: done, onChanged: (v) => setState(() => done = v)),
        if (t != null) ...[
          ListTile(tileColor: Colors.grey.shade100, title: const Text('Time spent'), trailing: Text(_spent(d.forTask(t.id)).replaceAll('No sessions yet', '0 sessions, 0 min'))),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () { d.deleteTask(t.id); Navigator.pop(context); },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete task'),
          ),
        ],
      ]),
    );
  }
}
