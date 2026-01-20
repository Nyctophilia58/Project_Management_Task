import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/buyer/providers/buyer_providers.dart';
import '../../shared/models/task.dart';

class TaskActions {
  static Future<void> payForTask({
    required BuildContext context,
    required WidgetRef ref,
    required Task task,
  }) async {
    try {
      await ref.read(buyerServiceProvider).payForTask(task.id, task.amountDue);
      await ref.refresh(projectTasksProvider(task.projectId).future);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment successful! You can now download the solution.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<void> downloadZip({
    required BuildContext context,
    required WidgetRef ref,
    required Task task,
  }) async {
    if (task.zipPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No solution file available')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting download...')),
    );

    try {
      final filename = 'solution_task_${task.id}.zip';
      await ref.read(buyerServiceProvider).downloadZip(task.zipPath!, filename);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download complete! Check your Downloads folder.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e'), backgroundColor: Colors.red),
      );
    }
  }
}