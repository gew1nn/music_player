import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/main_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

// state class for AuthScreen
class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  // controllers for text fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _isLogin = true;  // flag to toggle between login and signup modes

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      UserCredential userCredential;
      if (_isLogin) {  // login mode
        userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {  // signup mode
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        String fullName =
            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
        await userCredential.user!.updateDisplayName(fullName);  // update the display name after signup
      }

      // store user data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'email': _emailController.text.trim(),
        'role': 'user',
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } catch (error) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Error', style: TextStyle(color: Colors.white)),
          content: Text(error.toString(), style: const TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close', style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      );
    }
  }

  // method to toggle between login and signup modes
  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  void dispose() {
    // dispose the text controllers when the screen is disposed
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(  // allow scrolling if the keyboard is shown
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,  // minimize column size
            children: [
              const Icon(Icons.music_note, size: 80, color: Colors.green),  // music note icon
              const SizedBox(height: 20),
              Text(
                _isLogin ? 'Sign in' : 'Sign up',  // toggle text based on auth mode
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,  // assign form key
                child: Column(
                  children: [
                    if (!_isLogin) ...[  // display name fields only in signup mode
                      _buildTextField(_firstNameController, 'Name'),
                      _buildTextField(_lastNameController, 'Surname'),
                    ],
                    _buildTextField(_emailController, 'Email', TextInputType.emailAddress),  // email field
                    _buildTextField(_passwordController, 'Password', TextInputType.visiblePassword, true),  // password field
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,  // green button color
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      ),
                      onPressed: _submit,
                      child: Text(
                        _isLogin ? 'Sign in' : 'Sign up',
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    TextButton(
                      onPressed: _toggleAuthMode,  // toggle between login and signup
                      child: Text(
                        _isLogin ? 'Create account' : 'Already have one? Sign in',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, [TextInputType type = TextInputType.text, bool obscureText = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,  // controller for text input
        keyboardType: type,  // keyboard type (email, text, etc.)
        obscureText: obscureText,  // show password as dots if true
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,  // label text for the field
          labelStyle: const TextStyle(color: Colors.grey),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),  // rounded border for the text field
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.green),  // green border on focus
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {  // check if the field is not empty
            return 'Enter $label';
          }
          return null;
        },
      ),
    );
  }
}
