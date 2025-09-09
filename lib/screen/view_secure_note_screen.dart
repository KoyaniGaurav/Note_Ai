import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:note_ai/models/note_model.dart';

class ViewSecureNoteScreen extends StatefulWidget {
  const ViewSecureNoteScreen({super.key});

  @override
  State<ViewSecureNoteScreen> createState() => _ViewSecureNoteScreenState();
}

class _ViewSecureNoteScreenState extends State<ViewSecureNoteScreen> {
  bool isUnlocked = false;
  String? storedPassword;

  final TextEditingController _passwordController = TextEditingController();

  String _formatDate(DateTime date) {
    return DateFormat('EEE, MMM d • hh:mm a').format(date);
  }

  @override
  void initState() {
    super.initState();
    _loadStoredPassword();
  }

  Future<void> _loadStoredPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      storedPassword = prefs.getString("secure_note_password");
    });
  }

  void _checkPassword() {
    if (_passwordController.text.trim() == storedPassword) {
      setState(() {
        isUnlocked = true;
      });
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incorrect password")),
      );
    }
  }

  Future<void> _showPasswordDialog() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Password"),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Password",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_passwordController.text.trim().isNotEmpty) {
                  _checkPassword();
                }
              },
              child: const Text("Unlock"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final NoteModel note =
    ModalRoute.of(context)!.settings.arguments as NoteModel;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "View Secure Note",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (isUnlocked)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/editSecureNote',
                  arguments: note,
                );
              },
            ),
        ],
      ),

      body: isUnlocked
          ? SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              note.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Created At
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  "Created: ${_formatDate(note.createdAt)}",
                  style:
                  const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Secure Content
            const Text(
              "Secure Content",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                note.content,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      )
          : Center(
        child: ElevatedButton.icon(
          onPressed: _showPasswordDialog,
          icon: const Icon(Icons.lock_open),
          label: const Text("Unlock Secure Note"),
          style: ElevatedButton.styleFrom(
            padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
