// lib/models/note_model.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // Required for Timestamp

class Note {
  final String? id; // Nullable for new notes before they are saved to Firestore
  final String title;
  final String content;
  final DateTime timestamp;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.timestamp,
  });

  // Factory constructor to create a Note object from a Firestore document
  factory Note.fromMap(Map<String, dynamic> data, String id) {
    return Note(
      id: id,
      title: data['title'] ?? '', // Provide default empty string if null
      content: data['content'] ?? '', // Provide default empty string if null
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(), // Handle Timestamp conversion
    );
  }

  // Method to convert a Note object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'timestamp': timestamp,
    };
  }

  // Optional: For debugging or logging
  @override
  String toString() {
    return 'Note(id: $id, title: $title, content: $content, timestamp: $timestamp)';
  }
}