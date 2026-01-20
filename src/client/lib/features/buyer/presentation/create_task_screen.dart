import 'package:client/features/buyer/providers/buyer_providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/simple_user.dart';
import '../../../shared/models/project.dart';
import '../../../shared/models/task_create.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  final Project project;
  const CreateTaskScreen({super.key, required this.project});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _rateController = TextEditingController();
  SimpleUser? _selectedDev;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final developersAsync = ref.watch(developersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Task')),
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
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
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
                  data: (devs) {
                    if (devs.isEmpty) {
                      return const Text('No developers registered yet', style: TextStyle(color: Colors.red));
                    }
                    return DropdownButtonFormField<SimpleUser>(
                      value: _selectedDev,
                      hint: const Text('Assign to Developer'),
                      items: devs.map((dev) => DropdownMenuItem(value: dev, child: Text(dev.email))).toList(),
                      onChanged: (val) => setState(() => _selectedDev = val),
                      validator: (_) => _selectedDev == null ? 'Select a developer' : null,
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Error loading developers: $e'),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _createTask,
                    child: _loading ? const CircularProgressIndicator() : const Text('Create Task'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate() || _selectedDev == null) return;

    setState(() => _loading = true);

    try {
      final taskCreate = TaskCreate(
        projectId: widget.project.id,
        developerId: _selectedDev!.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        hourlyRate: double.parse(_rateController.text),
      );

      await ref.read(buyerServiceProvider).createTask(taskCreate);
      await ref.refresh(projectTasksProvider(widget.project.id).future);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task created!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }
}