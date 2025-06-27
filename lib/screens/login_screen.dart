// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import '../utils/app_colors.dart';
import 'package:flutter/services.dart'; // For clipboard copy in notes screen ID


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false; // New state for loading indicator

  Future<void> _loginPressed() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        // On successful login, the auth state listener in main.dart will redirect
        // So, no explicit Navigator.push here.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged in successfully!')),
        );
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found') {
          message = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          message = 'Wrong password provided for that user.';
        } else {
          message = 'Login failed: ${e.message}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  void _signInWithGoogle() {
    debugPrint('Signing in with Google...');
    // TODO: Implement Google sign-in logic using google_sign_in package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google Sign-in not implemented yet.')),
    );
  }

  void _signInWithGitHub() {
    debugPrint('Signing in with GitHub...');
    // TODO: Implement GitHub sign-in logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('GitHub Sign-in not implemented yet.')),
    );
  }

  void _forgotPassword() {
    debugPrint('Forgot password pressed...');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Forgot Password functionality not implemented yet.')),
    );
    // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordPage()));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
            SizedBox(height: MediaQuery.of(context).padding.top + 40), // Spacing from top
            Text(
              'Welcome Back!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Sign in to continue to your account.',
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
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
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
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryLavender),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: AppColors.darkGrey.withOpacity(0.6),
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
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _isLoading
                      ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLavender))
                      : ElevatedButton(
                          onPressed: _loginPressed,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50), // Full width button
                          ),
                          child: const Text('Log In'),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(child: Divider(color: AppColors.darkGrey.withOpacity(0.3))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Or Log in with',
                    style: TextStyle(color: AppColors.darkGrey.withOpacity(0.7)),
                  ),
                ),
                Expanded(child: Divider(color: AppColors.darkGrey.withOpacity(0.3))),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google Sign-in Icon
                InkWell(
                  onTap: _signInWithGoogle,
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white,
                      border: Border.all(color: AppColors.lightLavender, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryLavender.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/google_logo.svg', // Path to your Google SVG asset
                      height: 30,
                      width: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                // GitHub Sign-in Icon
                InkWell(
                  onTap: _signInWithGitHub,
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white,
                      border: Border.all(color: AppColors.lightLavender, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryLavender.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/github_logo.svg', // Path to your GitHub SVG asset
                      height: 30,
                      width: 30,
                      colorFilter: const ColorFilter.mode(AppColors.darkGrey, BlendMode.srcIn), // GitHub logo is often dark, recolor it
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: TextStyle(color: AppColors.darkGrey.withOpacity(0.8)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/register');
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}