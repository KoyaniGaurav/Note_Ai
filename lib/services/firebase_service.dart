// services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/note_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserIfNotExists(User user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      final newUser = UserModel(
        uid: user.uid,
        name: user.displayName ?? "No Name",
        email: user.email ?? "",
        profilePic: user.photoURL ?? "",
        createdAt: DateTime.now(),
      );
      await docRef.set(newUser.toMap());
    }
  }

  Future<String?> getSecureNotePassword(String userId) async {
    if (userId.isEmpty) throw Exception("Invalid userId passed to getSecureNotePassword");
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data()?['secureNotePassword'];
  }

  Future<void> setSecureNotePassword(String userId, String password) async {
    await _firestore.collection('users').doc(userId).set({'secureNotePassword': password}, SetOptions(merge: true));
  }

  Future<void> addSecureNote(String userId, NoteModel note) async {
    await _firestore.collection('users').doc(userId).collection('secureNotes').add(note.toMap());
  }

  Future<String> addNote(NoteModel note) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      final notesRef = _firestore.collection('users').doc(user.uid).collection('notes');
      final docRef = note.id.isNotEmpty ? notesRef.doc(note.id) : notesRef.doc();
      final payload = note.toMap();
      print('DEBUG: writing note to path=${docRef.path} payload=$payload');
      await docRef.set(payload);
      print('DEBUG: write OK to ${docRef.path}');
      return docRef.id;
    } catch (e) {
      print('DEBUG: Error adding note: $e');
      rethrow;
    }
  }



  Future<List<NoteModel>> getNotes() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => NoteModel.fromMap(doc.id, doc.data())).toList();
  }

  Future<void> updateNote(NoteModel note) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .doc(note.id)
        .update(note.toMap());
  }

  Future<void> deleteNote(String noteId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .doc(noteId)
        .delete();
  }
}
