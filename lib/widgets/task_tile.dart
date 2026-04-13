import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskTile extends StatefulWidget {
  final Task task;
  final TaskService service;

  const TaskTile({super.key, required this.task, required this.service});

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  bool _expanded = false;
  final TextEditingController _subController = TextEditingController();

  @override
  void dispose() {
    _subController.dispose(); // prevent memory leaks
    super.dispose();
  }

  // Subtask helpers

  Future<void> _addSubtask() async {
    final text = _subController.text.trim();
    if (text.isEmpty) return;
    final updated = [
      ...widget.task.subtasks,
      {'title': text, 'isDone': false},
    ];
    await widget.service.updateSubtasks(widget.task, updated);
    _subController.clear();
  }

  Future<void> _toggleSubtask(int index) async {
    final updated = List<Map<String, dynamic>>.from(widget.task.subtasks);
    updated[index] = {
      ...updated[index],
      'isDone': !(updated[index]['isDone'] as bool? ?? false),
    };
    await widget.service.updateSubtasks(widget.task, updated);
  }

  Future<void> _deleteSubtask(int index) async {
    final updated = List<Map<String, dynamic>>.from(widget.task.subtasks)
      ..removeAt(index);
    await widget.service.updateSubtasks(widget.task, updated);
  }

  // Delete task with confirmation

  Future<void> _confirmDelete() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('Remove "${widget.task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (yes == true) await widget.service.deleteTask(widget.task.id);
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        children: [
          // Main row
          ListTile(
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (_) => widget.service.toggleTask(task),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                color: task.isCompleted ? Colors.grey : null,
              ),
            ),
            subtitle: task.subtasks.isNotEmpty
                ? Text(
                    '${task.subtasks.where((s) => s['isDone'] == true).length}/${task.subtasks.length} subtasks done',
                    style: const TextStyle(fontSize: 12),
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Expand / collapse subtasks
                IconButton(
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  tooltip: 'Subtasks',
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
                // Delete
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Delete task',
                  onPressed: _confirmDelete,
                ),
              ],
            ),
          ),

          // Subtask panel
          if (_expanded) ...[
            const Divider(height: 1),
            ...List.generate(task.subtasks.length, (i) {
              final sub = task.subtasks[i];
              final isDone = sub['isDone'] as bool? ?? false;
              return ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 32),
                leading: Checkbox(
                  value: isDone,
                  onChanged: (_) => _toggleSubtask(i),
                ),
                title: Text(
                  sub['title'] as String? ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone ? Colors.grey : null,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => _deleteSubtask(i),
                ),
              );
            }),
            // Add subtask row
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 4, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subController,
                      decoration: const InputDecoration(
                        hintText: 'Add subtask…',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _addSubtask(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addSubtask,
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
