import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:note_ai/models/note_model.dart';
import 'package:note_ai/services/firebase_service.dart';

class EditSecureNoteScreen extends StatefulWidget {
  final NoteModel note;

  const EditSecureNoteScreen({super.key, required this.note});

  @override
  State<EditSecureNoteScreen> createState() => _EditSecureNoteScreenState();
}

class _EditSecureNoteScreenState extends State<EditSecureNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String? _storedPassword;
  bool isUnlocked = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(
      text: widget.note.content is String ? widget.note.content : "",
    );

    _initPasswordFlow();
  }

  /// Initialize password flow
  Future<void> _initPasswordFlow() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _storedPassword = prefs.getString("secure_note_password");

    if (_storedPassword == null) {
      // No password set → ask to create one
      await _showSetPasswordDialog();
      await _showEnterPasswordDialog();
    } else {
      // Ask for password before editing
      await _showEnterPasswordDialog();
    }
  }

  /// Set a new password dialog
  Future<void> _showSetPasswordDialog() async {
    TextEditingController passController = TextEditingController();
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Set Password"),
          content: TextField(
            controller: passController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Enter new password",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (passController.text.trim().isNotEmpty) {
                  SharedPreferences prefs =
                  await SharedPreferences.getInstance();
                  await prefs.setString(
                      "secure_note_password", passController.text.trim());
                  _storedPassword = passController.text.trim();
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  /// Enter password before editing
  Future<void> _showEnterPasswordDialog() async {
    TextEditingController passController = TextEditingController();
    bool passwordCorrect = false;

    while (!passwordCorrect && mounted) {
      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Enter Password"),
            content: TextField(
              controller: passController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (passController.text.trim() == _storedPassword) {
                    passwordCorrect = true;
                    setState(() => isUnlocked = true);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Incorrect password")),
                    );
                  }
                },
                child: const Text("Unlock"),
              ),
            ],
          );
        },
      );
    }
  }

  /// Save updated note
  Future<void> _updateSecureNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and content are required')),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final updatedNote = widget.note.copyWith(
        title: title,
        content: content,
        updatedAt: DateTime.now(),
      );

      await FirebaseService().updateNote(updatedNote);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Secure note updated successfully')),
      );

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
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Secure Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: isUnlocked && !isSaving ? _updateSecureNote : null,
          ),
        ],
      ),
      body: isUnlocked
          ? Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Secure Content',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              maxLines: 8,
            ),
            const SizedBox(height: 16),
          ],
        ),
      )
          : const Center(
        child: Text(
          "Please unlock to view or edit this secure note",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
