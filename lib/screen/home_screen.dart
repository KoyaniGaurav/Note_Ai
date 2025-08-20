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
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Note AI"),
        actions: [
          CircleAvatar(
            backgroundImage: NetworkImage(user.photoURL ?? ''),
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 20),
          const Expanded(child: NotesList()),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: () {
          Navigator.pushNamed(context, '/selectNoteType');
        },
        child: const Icon(Icons.add),
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,


      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                iconSize: 22,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.home),
                onPressed: () {
                  // Add Home navigation logic here
                },
              ),
              const SizedBox(width: 30), // space for the FAB
              IconButton(
                iconSize: 22,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.search),
                onPressed: () {
                  // Note search
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class NotesList extends StatelessWidget {
  const NotesList({super.key});

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
          return const Center(child: Text("No notes yet"));
        }

        final notes = snapshot.data!.docs;

        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final doc = notes[index];
            final note = NoteModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);

            return Card(
              elevation: 0,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(note.title,style : TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Type: ${note.type}"),
                trailing : Text(
                  "Created at: ${note.createdAt.toLocal().toString().split(' ')[0]} ${note.createdAt.toLocal().toString().split(' ')[1].split('.')[0]}",
                ),
              ),
            );
          },
        );
      },
    );
  }
}
