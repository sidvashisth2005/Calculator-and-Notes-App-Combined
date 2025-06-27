// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import '../utils/app_colors.dart';
import 'calculator_screen.dart';
import 'notes_screen.dart';
import '../services/firebase_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Apps',
          style: TextStyle(color: AppColors.darkGrey, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.darkGrey),
            onPressed: () async {
              await FirebaseService.signOut();
              // After logout, the StreamBuilder in main.dart will redirect to Login
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully!')),
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Calculator App Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CalculatorScreen()),
                  );
                },
                icon: const Icon(Icons.calculate),
                label: const Text('Calculator App'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: AppColors.primaryLavender.withOpacity(0.9),
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  elevation: 8,
                ),
              ),
              const SizedBox(height: 30),
              // Notes App Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotesScreen()),
                  );
                },
                icon: const Icon(Icons.notes),
                label: const Text('Notes App'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: AppColors.primaryLavender,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  elevation: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}