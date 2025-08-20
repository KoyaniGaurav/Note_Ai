import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_ai/models/user_model.dart';
import '../models/note_model.dart';

// this is fire base service that will handle all the firebase operations like add , get , update and delete notes.
class FirebaseService {


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

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    return doc.data()?['secureNotePassword'];
  }


  Future<void> setSecureNotePassword(String userId, String password) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set({'secureNotePassword': password}, SetOptions(merge: true));
  }

  Future<void> addSecureNote(String userId, NoteModel note) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('secureNotes')
        .add(note.toMap());
  }


  // to work with firebase first we need ins. of the auth to check is user is their or not.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // then is user so we want to do crud op. so need to of firestore.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addNote(NoteModel note) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .add(note.toMap());
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

    return snapshot.docs
        .map((doc) => NoteModel.fromMap(doc.id, doc.data()))
        .toList();
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
