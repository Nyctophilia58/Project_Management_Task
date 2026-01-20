import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/utils/task_actions.dart';
import '../providers/buyer_providers.dart';
import '../../../shared/models/task.dart';

class TaskDetailScreen extends ConsumerWidget {
  final Task task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(task.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(task.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            const Text('Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDetailRow('Status', task.status.toUpperCase()),
            _buildDetailRow('Hourly Rate', '\$${task.hourlyRate.toStringAsFixed(2)}'),
            if (task.developerId != null)
              _buildDetailRow('Assigned Developer ID', task.developerId.toString()),
            if (task.hoursSpent != null)
              _buildDetailRow('Hours Spent', task.hoursSpent!.toStringAsFixed(1)),
            if (task.hoursSpent != null)
              _buildDetailRow('Amount Due', '\$${task.amountDue.toStringAsFixed(2)}', color: Colors.amber),

            const SizedBox(height: 30),

            // Action buttons
            if (task.status == 'submitted')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => TaskActions.payForTask(
                    context: context,
                    ref: ref,
                    task: task,
                  ),
                  child: const Text('Pay Now'),
                ),
              )
            else if (task.status == 'paid')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => TaskActions.downloadZip(
                    context: context,
                    ref: ref,
                    task: task,
                  ),
                  icon: const Icon(Icons.download),
                  label: const Text('Download ZIP Solution'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value, style: TextStyle(color: color))),
        ],
      ),
    );
  }
}