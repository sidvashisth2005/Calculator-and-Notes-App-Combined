// lib/screens/notes_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For clipboard
import '../utils/app_colors.dart';
import '../services/firebase_service.dart';
import '../models/note_model.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For accessing current user directly if needed


class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String? _displayUserId;

  @override
  void initState() {
    super.initState();
    // Get the initial user ID. It will be updated by auth state changes.
    _displayUserId = FirebaseService.auth.currentUser?.uid;

    // Listen to auth state changes to update the displayed user ID
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {
          _displayUserId = user?.uid;
        });
      }
    });
  }

  // Function to show Add/Edit Note dialog
  Future<void> _showNoteDialog({Note? note}) async {
    final TextEditingController titleController = TextEditingController(text: note?.title ?? '');
    final TextEditingController contentController = TextEditingController(text: note?.content ?? '');
    final bool isEditing = note != null;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(isEditing ? 'Edit Note' : 'Add New Note', style: const TextStyle(color: AppColors.darkGrey)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Note Title',
                    prefixIcon: const Icon(Icons.title, color: AppColors.primaryLavender),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: contentController,
                  decoration: InputDecoration(
                    hintText: 'Note Content',
                    prefixIcon: const Icon(Icons.description, color: AppColors.primaryLavender),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  maxLines: 5,
                  minLines: 3,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: AppColors.darkGrey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLavender,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(isEditing ? 'Update' : 'Add'),
              onPressed: () {
                final String title = titleController.text.trim();
                final String content = contentController.text.trim();

                if (title.isNotEmpty || content.isNotEmpty) {
                  if (isEditing) {
                    FirebaseService.updateNote(
                      Note(
                        id: note!.id,
                        title: title,
                        content: content,
                        timestamp: DateTime.now(), // Update timestamp on edit
                      ),
                    );
                  } else {
                    FirebaseService.addNote(
                      Note(
                        title: title,
                        content: content,
                        timestamp: DateTime.now(),
                      ),
                    );
                  }
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note cannot be empty!')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // You can safely remove the _confirmDelete method from here if it's unused.
  // The Dismissible widget directly handles the confirmation logic now.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Notes',
          style: TextStyle(color: AppColors.darkGrey, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.darkGrey),
        actions: [
          if (_displayUserId != null) // Use _displayUserId for the chip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Tooltip(
                message: 'Your User ID: $_displayUserId\nClick to copy',
                child: GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _displayUserId!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User ID copied to clipboard!')),
                    );
                  },
                  child: Chip(
                    label: Text(
                      'ID: ${_displayUserId!.substring(0, 4)}...', // Show a truncated ID
                      style: const TextStyle(fontSize: 12, color: AppColors.darkGrey),
                    ),
                    backgroundColor: AppColors.lightLavender,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: FirebaseService.currentUserId == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLavender),
                  ),
                  SizedBox(height: 16),
                  Text('Fetching user data...'),
                ],
              ),
            )
          : StreamBuilder<List<Note>>(
              stream: FirebaseService.getNotes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLavender),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: AppColors.errorRed),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.note_alt_outlined, size: 80, color: AppColors.lightLavender),
                        const SizedBox(height: 20),
                        Text(
                          'No notes yet!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGrey.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tap the "+" button to add your first note.',
                          style: TextStyle(fontSize: 16, color: AppColors.darkGrey.withOpacity(0.6)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final notes = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Dismissible(
                      key: Key(note.id!), // Unique key for Dismissible
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: AppColors.errorRed.withOpacity(0.8),
                        child: const Icon(Icons.delete, color: AppColors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              title: const Text("Confirm Deletion", style: TextStyle(color: AppColors.darkGrey)),
                              content: const Text("Are you sure you want to delete this note?", style: TextStyle(color: AppColors.darkGrey)),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text("Cancel", style: TextStyle(color: AppColors.darkGrey)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.errorRed,
                                    foregroundColor: AppColors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text("Delete"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) {
                        if (note.id != null) {
                          FirebaseService.deleteNote(note.id!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Note "${note.title.isNotEmpty ? note.title : 'Untitled'}" deleted.'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 4,
                        color: AppColors.white,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            note.title.isNotEmpty ? note.title : 'Untitled Note',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.darkGrey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),
                              Text(
                                note.content,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.darkGrey.withOpacity(0.7),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Last updated: ${_formatDateTime(note.timestamp)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.darkGrey.withOpacity(0.5),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                          trailing: Icon(Icons.edit, color: AppColors.lightLavender),
                          onTap: () {
                            _showNoteDialog(note: note); // Allow editing
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(),
        backgroundColor: AppColors.primaryLavender,
        foregroundColor: AppColors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}