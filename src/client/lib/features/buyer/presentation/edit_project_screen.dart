import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/buyer_providers.dart';
import '../../../shared/models/project.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Edit Project'),
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
            child: Column(
              children: [
                // White Card for Form
                Card(
                  elevation: 12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit "${widget.project.title}"',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Title Field
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: 'Project Title',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: theme.primaryColor, width: 2),
                              ),
                            ),
                            validator: (v) => v?.trim().isEmpty ?? true ? 'Title is required' : null,
                          ),
                          const SizedBox(height: 20),

                          // Description Field
                          TextFormField(
                            controller: _descController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: theme.primaryColor, width: 2),
                              ),
                            ),
                            validator: (v) => v?.trim().isEmpty ?? true ? 'Description is required' : null,
                          ),
                          const SizedBox(height: 40),

                          // Update Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _update,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: _loading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                'Update Project',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
      // await ref.invalidate(myProjectsProvider);

      if (!mounted) return;
      Navigator.pop(context, updated);
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
    super.dispose();
  }
}