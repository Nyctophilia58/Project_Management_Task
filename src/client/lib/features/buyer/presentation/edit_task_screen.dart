import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/buyer_providers.dart';
import '../../../shared/models/task.dart';
import '../../../shared/models/task_create.dart';
import '../../../shared/models/simple_user.dart';

class EditTaskScreen extends ConsumerStatefulWidget {
  final Task task;
  const EditTaskScreen({super.key, required this.task});

  @override
  ConsumerState<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends ConsumerState<EditTaskScreen> {
  late final _titleController = TextEditingController(text: widget.task.title);
  late final _descController = TextEditingController(text: widget.task.description);
  late final _rateController = TextEditingController(text: widget.task.hourlyRate.toString());
  SimpleUser? _selectedDev;
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Pre-select current developer
    if (widget.task.developerId != null) {
      ref.read(developersProvider.future).then((devs) {
        _selectedDev = devs.firstWhere((dev) => dev.id == widget.task.developerId, orElse: () => devs[0]);
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final developersAsync = ref.watch(developersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Task Title', border: OutlineInputBorder()),
                  validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _rateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Hourly Rate (\$)', border: OutlineInputBorder()),
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Required';
                    if (double.tryParse(v!) == null) return 'Invalid number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                developersAsync.when(
                  data: (devs) => DropdownButtonFormField<SimpleUser>(
                    value: _selectedDev,
                    hint: const Text('Assign to Developer'),
                    items: devs.map((dev) => DropdownMenuItem(value: dev, child: Text(dev.email))).toList(),
                    onChanged: (val) => setState(() => _selectedDev = val),
                    validator: (_) => _selectedDev == null ? 'Select a developer' : null,
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _updateTask,
                    child: _loading ? const CircularProgressIndicator() : const Text('Update Task'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateTask() async {
    if (!_formKey.currentState!.validate() || _selectedDev == null) return;

    setState(() => _loading = true);

    try {
      final taskUpdate = TaskCreate(
        projectId: widget.task.projectId,
        developerId: _selectedDev!.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        hourlyRate: double.parse(_rateController.text),
      );

      await ref.read(buyerServiceProvider).updateTask(widget.task.id, taskUpdate);
      await ref.refresh(projectTasksProvider(widget.task.projectId).future);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task updated successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _rateController.dispose();
    super.dispose();
  }
}