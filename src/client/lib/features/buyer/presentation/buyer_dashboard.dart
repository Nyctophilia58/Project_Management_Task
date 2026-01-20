import 'package:client/features/buyer/presentation/project_detail_screen.dart';
import 'package:client/features/buyer/providers/buyer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/project.dart';
import 'create_project_screen.dart';
import 'edit_project_screen.dart';

class BuyerDashboard extends ConsumerWidget {
  const BuyerDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(myProjectsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Buyer Dashboard'), backgroundColor: Colors.blue),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateProjectScreen())),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.refresh(myProjectsProvider.future); // ← refresh instead of invalidate
        },
        child: projectsAsync.when(
          data: (projects) {
            if (projects.isEmpty) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(), // ← Critical for empty list
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: const Center(
                        child: Text('No projects yet. Create one!', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ),
                    ),
                  );
                },
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(), // ← Ensures pull-to-refresh works
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(project.title),
                    subtitle: Text(project.description),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          final updated = await Navigator.push<Project>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProjectScreen(project: project),
                            ),
                          );
                          if (updated != null) {
                            await ref.read(buyerServiceProvider).updateProject(project.id, updated);
                            ref.invalidate(myProjectsProvider);
                          }
                        } else if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Project'),
                              content: Text('Delete "${project.title}" and all its tasks?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await ref.read(buyerServiceProvider).deleteProject(project.id);
                            ref.invalidate(myProjectsProvider);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Project deleted')));
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: project)),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $err'),
                ElevatedButton(
                  onPressed: () => ref.refresh(myProjectsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteProject(BuildContext context, WidgetRef ref, Project project) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Delete "${project.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(buyerServiceProvider).deleteProject(project.id);
        ref.invalidate(myProjectsProvider);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Project deleted')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}