import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:note_ai/models/note_model.dart';
import 'package:note_ai/services/firebase_service.dart';

class QANoteScreen extends StatefulWidget {
  const QANoteScreen({super.key});

  @override
  State<QANoteScreen> createState() => _QANoteScreenState();
}

class _QANoteScreenState extends State<QANoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  List<Map<String, TextEditingController>> qaControllers = [];
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _addQAField();
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

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a title")),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }

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

    try {
      final note = NoteModel(
        id: '',
        type: "question_answer",
        title: title,
        content: qaData,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirebaseService().addNote(note);

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving note: $e")),
      );
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
        title: const Text("Q&A Note"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: isSaving ? null : _saveNote,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Title field
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Q&A pairs
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
                        TextField(
                          controller: qa['question'],
                          decoration: const InputDecoration(
                            labelText: "Question",
                            border: OutlineInputBorder(),
                          ),
                          maxLines: null,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: qa['answer'],
                          decoration: const InputDecoration(
                            labelText: "Answer",
                            border: OutlineInputBorder(),
                          ),
                          maxLines: null,
                        ),
                        const SizedBox(height: 8),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addQAField,
        child: const Icon(Icons.add),
        tooltip: "Add Q&A",
      ),
    );
  }
}
