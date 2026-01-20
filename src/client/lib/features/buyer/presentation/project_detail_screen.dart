import 'package:client/features/buyer/presentation/task_detail_screen.dart';
import 'package:client/features/buyer/providers/buyer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/project.dart';
import '../../../shared/models/task.dart';
import '../../../shared/utils/task_actions.dart';
import 'create_task_screen.dart';
import 'edit_task_screen.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final Project project;
  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(projectTasksProvider(project.id));

    return Scaffold(
      appBar: AppBar(title: Text(project.title)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CreateTaskScreen(project: project)),
        ),
        child: const Icon(Icons.add_task),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(project.description, style: const TextStyle(fontSize: 16)),
            const Divider(height: 32),
            const Text('Tasks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: tasksAsync.when(
                data: (tasks) => tasks.isEmpty
                    ? const Center(child: Text('No tasks yet. Create one!'))
                    : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      child: ListTile(
                        title: Text(task.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status: ${task.status.toUpperCase()}'),
                            if (task.hoursSpent != null)
                              Text('Hours: ${task.hoursSpent} × \$${task.hourlyRate} = \$${task.amountDue.toStringAsFixed(2)}'),
                            if (task.status == 'submitted')
                              Text('Amount due: \$${task.amountDue.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            task.status == 'todo'
                                ? PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => EditTaskScreen(task: task)),
                                  ).then((_) {
                                    ref.refresh(projectTasksProvider(task.projectId));
                                  });
                                } else if (value == 'delete') {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Task'),
                                      content: Text('Delete "${task.title}"?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await ref.read(buyerServiceProvider).deleteTask(task.id);
                                    ref.refresh(projectTasksProvider(task.projectId));
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task deleted')));
                                  }
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(value: 'delete', child: Text('Delete')),
                              ],
                            )
                                : task.status == 'submitted'
                                ? ElevatedButton(
                              onPressed: () => TaskActions.payForTask(
                                context: context,
                                ref: ref,
                                task: task,
                              ),
                              child: const Text('Pay Now'),
                            )
                                : task.status == 'paid'
                                ? ElevatedButton.icon(
                              onPressed: () => TaskActions.downloadZip(
                                context: context,
                                ref: ref,
                                task: task,
                              ),
                              icon: const Icon(Icons.download),
                              label: const Text('Download ZIP'),
                            )
                                : Text(task.status.toUpperCase()),
                          ],
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
                        )
                      ),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}