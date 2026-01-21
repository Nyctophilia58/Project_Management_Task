import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
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
  late final _rateController = TextEditingController(text: widget.task.hourlyRate.toStringAsFixed(2));
  SimpleUser? _selectedDev;
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    ref.read(developersProvider.future).then((devs) {
      _selectedDev = devs.firstWhereOrNull((dev) => dev.id == widget.task.developerId);
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final developersAsync = ref.watch(developersProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Edit Task'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor.withOpacity(0.8),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Task Information',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
          
                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Task Title',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.primaryColor, width: 2),
                          ),
                        ),
                        validator: (v) => v?.trim().isEmpty ?? true ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 20),
          
                      // Description
                      TextFormField(
                        controller: _descController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.primaryColor, width: 2),
                          ),
                        ),
                        validator: (v) => v?.trim().isEmpty ?? true ? 'Description is required' : null,
                      ),
                      const SizedBox(height: 20),
          
                      // Hourly Rate
                      TextFormField(
                        controller: _rateController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Hourly Rate (\$)',
                          prefixIcon: const Icon(Icons.attach_money),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.primaryColor, width: 2),
                          ),
                        ),
                        validator: (v) {
                          if (v?.isEmpty ?? true) return 'Rate is required';
                          final rate = double.tryParse(v!);
                          if (rate == null || rate <= 0) return 'Enter a valid positive number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
          
                      // Developer Dropdown
                      developersAsync.when(
                        data: (devs) {
                          if (devs.isEmpty) {
                            return const Text(
                              'No developers available',
                              style: TextStyle(color: Colors.redAccent),
                            );
                          }
                          return DropdownButtonFormField<SimpleUser>(
                            value: _selectedDev,
                            decoration: InputDecoration(
                              labelText: 'Assign to Developer',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: theme.primaryColor, width: 2),
                              ),
                            ),
                            items: devs.map((dev) {
                              return DropdownMenuItem<SimpleUser>(
                                value: dev,
                                child: Text(dev.email),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedDev = val),
                            validator: (_) => _selectedDev == null ? 'Please select a developer' : null,
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
                      ),
          
                      const SizedBox(height: 40),
          
                      // Update Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _updateTask,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 6,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            'Update Task',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
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