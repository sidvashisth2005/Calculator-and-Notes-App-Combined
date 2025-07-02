// lib/screens/registration_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import '../utils/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

// Enum for password strength
enum PasswordStrength { none, weak, medium, strong }

// Widget for password strength indicator
class PasswordStrengthIndicator extends StatelessWidget {
  final PasswordStrength strength;

  const PasswordStrengthIndicator({super.key, required this.strength});

  Color _getColor(PasswordStrength s) {
    switch (s) {
      case PasswordStrength.weak:
        return AppColors.errorRed;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return Colors.green;
      case PasswordStrength.none:
      default:
        return Colors.transparent;
    }
  }

  String _getText(PasswordStrength s) {
    switch (s) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
      case PasswordStrength.none:
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (strength != PasswordStrength.none)
          Text(
            _getText(strength),
            style: TextStyle(
              color: _getColor(strength),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        const SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: strength == PasswordStrength.none ? 0 : (strength.index + 1) / 3, // 1/3 for weak, 2/3 for medium, 1 for strong
            backgroundColor: AppColors.lightGrey.withOpacity(0.5),
            color: _getColor(strength),
            minHeight: 5,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ],
    );
  }
}


class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreedToTerms = false;
  PasswordStrength _passwordStrength = PasswordStrength.none;
  bool _isLoading = false; // New state for loading indicator

  // Function to check password strength
  void _checkPasswordStrength(String password) {
    setState(() {
      if (password.isEmpty) {
        _passwordStrength = PasswordStrength.none;
      } else if (password.length < 6) {
        _passwordStrength = PasswordStrength.weak;
      } else if (password.length < 8 || !password.contains(RegExp(r'[A-Z]')) || !password.contains(RegExp(r'[a-z]')) || !password.contains(RegExp(r'[0-9]')) || !password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        // Medium if less than 8 or missing uppercase, lowercase, number, or special char
        _passwordStrength = PasswordStrength.medium;
      } else {
        _passwordStrength = PasswordStrength.strong;
      }
    });
  }

  Future<void> _registerPressed() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreedToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please agree to the Terms & Conditions.')),
        );
        return;
      }

      setState(() {
        _isLoading = true; // Show loading indicator
      });

      // Use FirebaseService for registration
      final error = await FirebaseService.registerUser(
        name: _nameController.text,
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
        // Navigation to home is handled by the StreamBuilder in main.dart
      } else {
        String message;
        if (error == 'weak-password') {
          message = 'The password provided is too weak.';
        } else if (error == 'email-already-in-use') {
          message = 'An account already exists for that email.';
        } else {
          message = 'Registration failed: $error';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }

      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 40),
            Text(
              'Create Account',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Sign up to get started with our app.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.darkGrey.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      hintText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline, color: AppColors.primaryLavender),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.username],
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Username',
                      prefixIcon: Icon(Icons.account_circle_outlined, color: AppColors.primaryLavender),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      hintText: 'Email Address',
                      prefixIcon: Icon(Icons.email_outlined, color: AppColors.primaryLavender),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    onChanged: _checkPasswordStrength,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryLavender),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: AppColors.darkGrey.withOpacity(0.7),
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please create a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: PasswordStrengthIndicator(strength: _passwordStrength),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryLavender),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: AppColors.darkGrey.withOpacity(0.7),
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        onChanged: (bool? newValue) {
                          setState(() {
                            _agreedToTerms = newValue!;
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          'I agree to the ',
                          style: TextStyle(color: AppColors.darkGrey.withOpacity(0.8)),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to terms and conditions page or show dialog
                          debugPrint('Terms & Conditions pressed...');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Terms & Conditions link pressed.')),
                          );
                        },
                        child: const Text('Terms & Conditions'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _isLoading
                      ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLavender))
                      : ElevatedButton(
                          onPressed: _registerPressed,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50), // Full width button
                          ),
                          child: const Text('Register'),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account?",
                  style: TextStyle(color: AppColors.darkGrey.withOpacity(0.8)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text('Log In'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}