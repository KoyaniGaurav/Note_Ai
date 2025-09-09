import 'package:flutter/material.dart';

class SelectNoteTypeScreen extends StatefulWidget {
  const SelectNoteTypeScreen({super.key});

  @override
  State<SelectNoteTypeScreen> createState() => _SelectNoteTypeScreenState();
}

class _SelectNoteTypeScreenState extends State<SelectNoteTypeScreen> {
  String selectedType = 'text'; // Default selected

  final List<Map<String, dynamic>> noteTypes = [
    {'title': 'Text', 'type': 'text', 'icon': Icons.text_fields},
    {'title': 'Checklist', 'type': 'list', 'icon': Icons.check_box},
    {'title': 'Q. & A.', 'type': 'qa', 'icon': Icons.question_answer},
    {'title': 'Secure Note', 'type': 'secure', 'icon': Icons.lock},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Soft background
      appBar: AppBar(
        title: const Text(
          'Select Note Type',
          style: TextStyle(
            color: Color(0xFF1F1F1F),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF1F1F1F)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Choose a Note Type',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F1F1F),
              ),
            ),
            const SizedBox(height: 16),

            // Grid view for note types
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1,
                children: noteTypes.map((item) {
                  final isSelected = selectedType == item['type'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedType = item['type'];
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFFFFFF).withOpacity(0.15)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF6473D3)
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 6,
                            spreadRadius: 1,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item['icon'],
                            size: 40,
                            color: isSelected
                                ? const Color(0xFF6473D3)
                                : const Color(0xFF1F1F1F),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item['title'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF6473D3)
                                  : const Color(0xFF1F1F1F),
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
                  backgroundColor: const Color(0xFF272626), // Deep Purple
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  'Add ${noteTypes.firstWhere((e) => e['type'] == selectedType)['title']} Note',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
