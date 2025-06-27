// lib/services/firebase_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // For @required and debugPrint
import 'package:crypto/crypto.dart'; // For generating random userId for anonymous if needed
import 'dart:convert'; // For utf8 encoding

import '../models/note_model.dart'; // Local import for Note model

class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get db => FirebaseFirestore.instance;

  static String? get currentUserId => auth.currentUser?.uid;

  // --- Firestore Operations for Notes (already correct for current user ID) ---

  static Stream<List<Note>> getNotes() {
    final userId = currentUserId;
    if (userId == null) {
      return const Stream.empty();
    }
    final notesCollection = db
        .collection('artifacts')
        .doc('default-app-id')
        .collection('users')
        .doc(userId)
        .collection('notes');
    return notesCollection.orderBy('timestamp', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Note.fromMap(doc.data(), doc.id)).toList();
    });
  }

  static Future<void> addNote(Note note) async {
    final userId = currentUserId;
    if (userId == null) return;
    final notesCollection = db
        .collection('artifacts')
        .doc('default-app-id')
        .collection('users')
        .doc(userId)
        .collection('notes');
    await notesCollection.add(note.toMap());
  }

  static Future<void> updateNote(Note note) async {
    final userId = currentUserId;
    if (userId == null || note.id == null) return;
    final noteDoc = db
        .collection('artifacts')
        .doc('default-app-id')
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(note.id);
    await noteDoc.update(note.toMap());
  }

  static Future<void> deleteNote(String noteId) async {
    final userId = currentUserId;
    if (userId == null) return;
    final noteDoc = db
        .collection('artifacts')
        .doc('default-app-id')
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(noteId);
    await noteDoc.delete();
  }

  // --- Authentication Methods ---

  static Future<UserCredential?> registerWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential;
    } catch (e) {
      debugPrint('Registration error: \\$e');
      return null;
    }
  }

  static Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(email: email, password: password);
      return credential;
    } catch (e) {
      debugPrint('Sign in error: \\$e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await auth.signOut();
  }

  static User? get currentUser => auth.currentUser;

  // Register user and create Firestore profile
  static Future<String?> registerUser({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(email: email, password: password);
      await credential.user?.updateDisplayName(name);
      await db.collection('users').doc(credential.user!.uid).set({
        'name': name,
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.code; // Return error code
    } catch (e) {
      return e.toString();
    }
  }
}