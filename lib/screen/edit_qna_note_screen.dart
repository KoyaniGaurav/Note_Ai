import 'package:flutter/material.dart';
import 'package:note_ai/models/note_model.dart';
import 'package:note_ai/services/firebase_service.dart';

class EditQANoteScreen extends StatefulWidget {
  final NoteModel note;

  const EditQANoteScreen({super.key, required this.note});

  @override
  State<EditQANoteScreen> createState() => _EditQANoteScreenState();
}

class _EditQANoteScreenState extends State<EditQANoteScreen> {
  late TextEditingController _titleController;
  List<Map<String, TextEditingController>> qaControllers = [];
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    // Initialize title controller
    _titleController = TextEditingController(text: widget.note.title);

    // Pre-fill Q&A fields if note has existing data
    if (widget.note.content is List) {
      final qaList = widget.note.content as List;
      for (var qa in qaList) {
        qaControllers.add({
          'question': TextEditingController(text: qa['question'] ?? ''),
          'answer': TextEditingController(text: qa['answer'] ?? ''),
        });
      }
    }

    // If no Q&A exists, add one empty field
    if (qaControllers.isEmpty) {
      _addQAField();
    }
  }

  void _addQAField() {
    setState(() {
      qaControllers.add({
        'question': TextEditingController(),
        'answer': TextEditingController(),
      });
    });
  }

  void _removeQAField(int index) {
    setState(() {
      qaControllers.removeAt(index);
    });
  }

  Future<void> _updateNote() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a title")),
      );
      return;
    }

    // Collect Q&A data
    List<Map<String, String>> qaData = [];
    for (var qa in qaControllers) {
      final question = qa['question']!.text.trim();
      final answer = qa['answer']!.text.trim();

      if (question.isNotEmpty || answer.isNotEmpty) {
        qaData.add({'question': question, 'answer': answer});
      }
    }

    if (qaData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add at least one Q&A pair")),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final updatedNote = widget.note.copyWith(
        title: title,
        content: qaData,
        updatedAt: DateTime.now(),
      );

      await FirebaseService().updateNote(updatedNote);

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating note: $e")),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var qa in qaControllers) {
      qa['question']?.dispose();
      qa['answer']?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Q&A Note"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: isSaving ? null : _updateNote,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Title Field
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Q&A Fields
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: qaControllers.length,
              itemBuilder: (context, index) {
                final qa = qaControllers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        // Question Input
                        TextField(
                          controller: qa['question'],
                          decoration: const InputDecoration(
                            labelText: "Question",
                            border: OutlineInputBorder(),
                          ),
                          maxLines: null,
                        ),
                        const SizedBox(height: 12),

                        // Answer Input
                        TextField(
                          controller: qa['answer'],
                          decoration: const InputDecoration(
                            labelText: "Answer",
                            border: OutlineInputBorder(),
                          ),
                          maxLines: null,
                        ),
                        const SizedBox(height: 8),

                        // Remove Button
                        if (qaControllers.length > 1)
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeQAField(index),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      // Floating Button to Add Q&A Pair
      floatingActionButton: FloatingActionButton(
        onPressed: _addQAField,
        child: const Icon(Icons.add),
        tooltip: "Add Q&A Pair",
      ),
    );
  }
}
