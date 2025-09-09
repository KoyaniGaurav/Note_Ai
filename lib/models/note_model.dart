import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String type;
  final String title;
  final dynamic content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? reminderTime;
  final String? summary;
  final String? aiAnswer;
  final String? password;

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

  NoteModel copyWith({
    String? id,
    String? type,
    String? title,
    dynamic content,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? reminderTime,
    String? summary,
    String? aiAnswer,
    String? password,
  }) {
    return NoteModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reminderTime: reminderTime ?? this.reminderTime,
      summary: summary ?? this.summary,
      aiAnswer: aiAnswer ?? this.aiAnswer,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'reminderTime': reminderTime != null ? Timestamp.fromDate(reminderTime!) : null,
      'summary': summary,
      'aiAnswer': aiAnswer,
      'password': password,
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  factory NoteModel.fromMap(String id, Map<String, dynamic> map) {
    return NoteModel(
      id: id,
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      content: map['content'],
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
      reminderTime: map['reminderTime'] != null ? _parseDate(map['reminderTime']) : null,
      summary: map['summary'],
      aiAnswer: map['aiAnswer'],
      password: map['password'],
    );
  }
}
