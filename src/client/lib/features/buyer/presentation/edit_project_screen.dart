

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/project.dart';
import '../providers/buyer_providers.dart';

class EditProjectScreen extends ConsumerStatefulWidget {
  final Project project;
  const EditProjectScreen({super.key, required this.project});

  @override
  ConsumerState<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends ConsumerState<EditProjectScreen> {
  late final _titleController = TextEditingController(text: widget.project.title);
  late final _descController = TextEditingController(text: widget.project.description);
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Project')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _update,
                  child: _loading ? const CircularProgressIndicator() : const Text('Update Project'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final updated = Project(
        id: widget.project.id,
        buyerId: widget.project.buyerId,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
      );

      await ref.read(buyerServiceProvider).updateProject(widget.project.id, updated);
      if (!mounted) return;
      Navigator.pop(context, updated);
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
    super.dispose();
  }
}