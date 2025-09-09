import 'package:flutter/material.dart';
import 'package:note_ai/models/note_model.dart';
import 'package:note_ai/services/firebase_service.dart';

class EditTextNoteScreen extends StatefulWidget {
  final NoteModel note;
  const EditTextNoteScreen({super.key, required this.note});

  @override
  State<EditTextNoteScreen> createState() => _EditTextNoteScreenState();
}

class _EditTextNoteScreenState extends State<EditTextNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  bool isSaving = false;
  String? aiSummary;
  DateTime? reminderTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(
      text: widget.note.content is String ? widget.note.content : '',
    );
    aiSummary = widget.note.summary;
    reminderTime = widget.note.reminderTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Function to set reminder
  Future<void> _setReminder() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: reminderTime ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: reminderTime != null
            ? TimeOfDay.fromDateTime(reminderTime!)
            : TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          reminderTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  // Function to generate AI summary (dummy for now)
  Future<void> _generateAISummary() async {
    setState(() {
      aiSummary =
      "This is a placeholder AI summary. Later, integrate your AI API here.";
    });
  }

  // Function to save the edited note
  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and content are required")),
      );
      return;
    }

    setState(() => isSaving = true);

    final updatedNote = widget.note.copyWith(
      title: title,
      content: content,
      summary: aiSummary,
      reminderTime: reminderTime,
      updatedAt: DateTime.now(),
    );

    try {
      await FirebaseService().updateNote(updatedNote);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Note updated successfully")),
      );
      Navigator.pop(context, updatedNote);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update note: $e")),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Text Note"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: isSaving ? null : _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Title Field
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Content Field
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Set Reminder Button
            ElevatedButton.icon(
              icon: const Icon(Icons.access_alarm),
              label: Text(
                reminderTime == null
                    ? 'Set Reminder'
                    : 'Reminder: ${reminderTime.toString().split('.')[0]}',
              ),
              onPressed: _setReminder,
            ),
            const SizedBox(height: 16),

            // AI Summary Button
            ElevatedButton.icon(
              icon: const Icon(Icons.auto_fix_high),
              label: const Text("Get AI Summary"),
              onPressed: _generateAISummary,
            ),

            // Show AI Summary
            if (aiSummary != null && aiSummary!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                "AI Summary:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(aiSummary!),
            ],
          ],
        ),
      ),
    );
  }
}
