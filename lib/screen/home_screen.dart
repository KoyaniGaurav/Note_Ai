import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:note_ai/models/note_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "User not logged in",
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Note AI",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          CircleAvatar(
            backgroundImage: NetworkImage(user.photoURL ?? ''),
            radius: 18,
          ),
          const SizedBox(width: 16),
        ],
      ),

      body: const Padding(
        padding: EdgeInsets.all(12.0),
        child: NotesVerticalList(),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.pushNamed(context, '/selectNoteType');
        },
        child: const Icon(Icons.add, size: 28, color: Colors.white),
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 55,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                iconSize: 24,
                icon: const Icon(Icons.home),
                onPressed: () {},
              ),
              const SizedBox(width: 30),
              IconButton(
                iconSize: 24,
                icon: const Icon(Icons.search),
                onPressed: () {
                  Navigator.pushNamed(context, '/searchNote');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotesVerticalList extends StatelessWidget {
  const NotesVerticalList({super.key});

  Future<void> _deleteNote(BuildContext context, String docId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notes')
        .doc(docId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notes')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No notes yet. Start by adding one!",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final notes = snapshot.data!.docs;

        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final doc = notes[index];
            final note =
            NoteModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

                // Title & Subtitle
                title: Text(
                  note.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      "Type: ${note.type}",
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Created: ${note.createdAt.toLocal().toString().split(' ')[0]}",
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),

                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'view') {
                      if (note.type == 'text') {
                        Navigator.pushNamed(context, '/viewTextNote', arguments: note);
                      } else if (note.type == 'checklist') {
                        Navigator.pushNamed(context, '/viewChecklistNote', arguments: note);
                      } else if (note.type == 'qa') {
                        Navigator.pushNamed(context, '/viewQANote', arguments: note);
                      } else if (note.type == 'secure') {
                        Navigator.pushNamed(context, '/viewSecureNote', arguments: note);
                      }
                    }
                    else if (value == 'edit') {
                      if (note.type == 'text') {
                        Navigator.pushNamed(context, '/editTextNote', arguments: note);
                      } else if (note.type == 'checklist') {
                        Navigator.pushNamed(context, '/editChecklistNote', arguments: note);
                      } else if (note.type == 'qa') {
                        Navigator.pushNamed(context, '/editQANote', arguments: note);
                      } else if (note.type == 'secure') {
                        Navigator.pushNamed(context, '/editSecureNote', arguments: note);
                      }
                    }
                    else if (value == 'delete') {
                      _deleteNote(context, note.id);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 18),
                          SizedBox(width: 8),
                          Text("View"),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text("Edit"),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
              ),
                    ),
            );
          },
        );
      },
    );
  }
}
