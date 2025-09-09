import 'package:flutter/material.dart';
import 'package:note_ai/models/note_model.dart';
import 'package:note_ai/services/firebase_service.dart';

class EditListNoteScreen extends StatefulWidget {
  final NoteModel note;

  const EditListNoteScreen({super.key, required this.note});

  @override
  State<EditListNoteScreen> createState() => _EditListNoteScreenState();
}

class _EditListNoteScreenState extends State<EditListNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _newItemController = TextEditingController();
  List<Map<String, dynamic>> checklistItems = [];
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    // Initialize existing title
    _titleController.text = widget.note.title;

    // Parse stored content into checklist items
    if (widget.note.content != null && widget.note.content is String) {
      final List<String> lines = widget.note.content.toString().split("\n");
      checklistItems = lines.map((line) {
        bool isDone = line.startsWith("[x]");
        return {
          "text": line.replaceAll("[x] ", "").replaceAll("[ ] ", ""),
          "isDone": isDone,
        };
      }).toList();
    }
  }

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
    final title = _titleController.text.trim();

    if (title.isEmpty || checklistItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and at least one checklist item are required')),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final updatedNote = widget.note.copyWith(
        title: title,
        content: checklistItems
            .map((e) => '${e['isDone'] ? '[x]' : '[ ]'} ${e['text']}')
            .join('\n'),
        updatedAt: DateTime.now(),
      );

      await FirebaseService().updateNote(updatedNote);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checklist updated successfully!')),
      );

      if (mounted) Navigator.pop(context, updatedNote);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update note: $e')),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Checklist Note'),
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
            // Title field
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),

            // Add checklist item input
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

            // Checklist items list
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
