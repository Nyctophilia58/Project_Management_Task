import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../shared/models/task.dart';
import '../providers/devloper_providers.dart';

class SubmitTaskScreen extends ConsumerStatefulWidget {
  final Task task;
  const SubmitTaskScreen({super.key, required this.task});

  @override
  ConsumerState<SubmitTaskScreen> createState() => _SubmitTaskScreenState();
}

class _SubmitTaskScreenState extends ConsumerState<SubmitTaskScreen> {
  final _hoursController = TextEditingController();
  PlatformFile? _zipFile;
  bool _loading = false;

  Future<void> _pickZip() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result != null) {
      setState(() => _zipFile = result.files.single);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Task: ${widget.task.title}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            TextField(
              controller: _hoursController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Hours Spent',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickZip,
              icon: const Icon(Icons.attach_file),
              label: Text(_zipFile == null ? 'Pick ZIP File' : 'ZIP: ${_zipFile!.name}'),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading || _zipFile == null ? null : _submit,
                child: _loading ? const CircularProgressIndicator() : const Text('Submit Solution'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final hours = double.tryParse(_hoursController.text);
    if (hours == null || hours <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid hours')));
      return;
    }

    setState(() => _loading = true);

    try {
      await ref.read(developerServiceProvider).submitTask(widget.task.id, hours, _zipFile!);
      await ref.refresh(myTasksProvider.future);
      if(!mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task submitted successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }
}