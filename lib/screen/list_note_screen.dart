import 'package:flutter/material.dart';
import 'package:note_ai/models/note_model.dart';
import 'package:note_ai/services/firebase_service.dart';

class ListNoteScreen extends StatefulWidget {
  const ListNoteScreen({super.key});

  @override
  State<ListNoteScreen> createState() => _ListNoteScreenState();
}

class _ListNoteScreenState extends State<ListNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  List<Map<String, dynamic>> checklistItems = [];

  final TextEditingController _newItemController = TextEditingController();
  bool isSaving = false;

  void _addChecklistItem() {
    final text = _newItemController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        checklistItems.add({'text': text, 'isDone': false});
        _newItemController.clear();
      });
    }
  }

  void _removeChecklistItem(int index) {
    setState(() {
      checklistItems.removeAt(index);
    });
  }

  void _toggleDone(int index) {
    setState(() {
      checklistItems[index]['isDone'] = !checklistItems[index]['isDone'];
    });
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty || checklistItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and at least one item is required')),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }

    setState(() => isSaving = true);

    final note = NoteModel(
      id: '',
      title: _titleController.text.trim(),
      type: 'list',
      content: checklistItems.map((e) => '${e['isDone'] ? '[x]' : '[ ]'} ${e['text']}').join('\n'),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      reminderTime: null,
      summary: null,
      aiAnswer: null,
    );

    await FirebaseService().addNote(note);

    setState(() => isSaving = false);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Checklist Note'),
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
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newItemController,
                    decoration: const InputDecoration(hintText: 'Add checklist item'),
                    onSubmitted: (_) => _addChecklistItem(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addChecklistItem,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Checklist items
            ...checklistItems.asMap().entries.map((entry) {
              int index = entry.key;
              var item = entry.value;
              return ListTile(
                leading: Checkbox(
                  value: item['isDone'],
                  onChanged: (_) => _toggleDone(index),
                ),
                title: Text(
                  item['text'],
                  style: TextStyle(
                    decoration: item['isDone'] ? TextDecoration.lineThrough : null,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeChecklistItem(index),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
