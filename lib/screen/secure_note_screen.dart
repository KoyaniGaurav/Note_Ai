import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:note_ai/models/note_model.dart';
import 'package:note_ai/services/firebase_service.dart';

class SecureNoteScreen extends StatefulWidget {
  const SecureNoteScreen({super.key});

  @override
  State<SecureNoteScreen> createState() => _SecureNoteScreenState();
}

class _SecureNoteScreenState extends State<SecureNoteScreen> {
  String? _storedPassword;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  bool isUnlocked = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _initPasswordFlow();
  }

  Future<void> _initPasswordFlow() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _storedPassword = prefs.getString("secure_note_password");

    if (_storedPassword == null) {
      await _showSetPasswordDialog();
      await _showEnterPasswordDialog();
    } else {
      await _showEnterPasswordDialog();
    }
  }

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
            decoration: const InputDecoration(labelText: "Enter new password"),
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

  Future<void> _saveSecureNote() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and content are required')),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }

    setState(() => isSaving = true);

    final note = NoteModel(
      id: '',
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      type: 'secure',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      summary: null,
      aiAnswer: null,
      reminderTime: null,
    );

    await FirebaseService().addNote(note);

    setState(() => isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Secure note saved successfully')),
    );

    _titleController.clear();
    _contentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Text Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: isSaving ? null : _saveSecureNote,
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
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Secure Content'),
              maxLines: 8,
            ),
            const SizedBox(height: 16),
          ],
        ),
      )
          : const Center(child: Text("Please unlock to view or add secure notes")),
    );
  }
}
