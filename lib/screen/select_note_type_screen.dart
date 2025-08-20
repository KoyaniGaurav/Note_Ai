import 'package:flutter/material.dart';

class SelectNoteTypeScreen extends StatefulWidget {
  const SelectNoteTypeScreen({super.key});

  @override
  State<SelectNoteTypeScreen> createState() => _SelectNoteTypeScreenState();
}

class _SelectNoteTypeScreenState extends State<SelectNoteTypeScreen> {
  String selectedType = 'text'; // default selected

  final List<Map<String, dynamic>> noteTypes = [
    {'title': 'Text', 'type': 'text', 'icon': Icons.text_fields},
    {'title': 'Checklist', 'type': 'list', 'icon': Icons.check_box},
    {'title': 'Q. & A.', 'type': 'qa', 'icon': Icons.question_answer},
    {'title': 'Secure Note', 'type': 'secure', 'icon': Icons.lock},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Note Type'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Choose a Note Type',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Grid view for note types
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
                children: noteTypes.map((item) {
                  final isSelected = selectedType == item['type'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedType = item['type'];
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(item['icon'], size: 40, color: isSelected ? Colors.blue : Colors.black87),
                          const SizedBox(height: 10),
                          Text(
                            item['title'],
                            style: TextStyle(
                              fontSize: 16,
                              color: isSelected ? Colors.blue : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Bottom button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/${selectedType}Note',
                    arguments: {'type': selectedType},
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.black,
                ),
                child: Text(
                  'Add ${noteTypes.firstWhere((e) => e['type'] == selectedType)['title']} Note',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
