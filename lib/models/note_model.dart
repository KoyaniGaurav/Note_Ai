import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel{

  // all the filds that are in the note.
  final String id;
  final String type; // text , list , que. & ans. and secure note.
  final String title;
  final dynamic content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? reminderTime;
  final String? summary;
  final String? aiAnswer;
  final String? password;

  // contructor to initialize the note model
  NoteModel({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.reminderTime,
    this.summary,
    this.aiAnswer,
    this.password,
  });

  // this is convert the note object to the map so we can store it in firebase
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'reminderTime': reminderTime,
      'summary': summary,
      'aiAnswer': aiAnswer,
      'password': password,
    };
  }

  // this is convert the map to the nothe object so we can use then in the Note_AI.
  factory NoteModel.fromMap(String id, Map<String, dynamic> map) {
    return NoteModel(
      id: id,
      type: map['type'],
      title: map['title'],
      content: map['content'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      reminderTime: map['reminderTime'] != null ? (map['reminderTime'] as Timestamp).toDate() : null,
      summary: map['summary'],
      aiAnswer: map['aiAnswer'],
      password: map['password'],
    );
  }
}