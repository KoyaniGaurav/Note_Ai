import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note_ai/models/note_model.dart';

class ViewChecklistNoteScreen extends StatelessWidget {
  const ViewChecklistNoteScreen({super.key});

  String _formatDate(DateTime date) {
    return DateFormat('EEE, MMM d • hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final NoteModel note =
    ModalRoute.of(context)!.settings.arguments as NoteModel;

    // Convert checklist content (stored as a single string) into a list
    final List<String> checklistItems = note.content.split('\n').where((item) => item.trim().isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "View Checklist",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/editChecklistNote',
                arguments: note,
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
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
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  "Created: ${DateFormat('MMM dd, yyyy • hh:mm a').format(note.createdAt)}",
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Checklist Section
            const Text(
              "Checklist Items",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: checklistItems.isNotEmpty
                  ? Column(
                children: checklistItems.map((item) {
                  return Row(
                    children: [
                      const Icon(Icons.check_box_outlined,
                          color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.trim(),
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              )
                  : const Text(
                "No checklist items available",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
