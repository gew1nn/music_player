import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_panel.dart';
import 'auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _isEditing = false;

  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // check if user has admin privileges
    _checkIfAdmin();
  }

  // method to load user data from firebase
  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final displayName = user.displayName ?? '';
      final names = displayName.split(' ');
      _firstNameController.text = names.isNotEmpty ? names[0] : '';
      _lastNameController.text = names.length > 1 ? names[1] : '';
    }
  }

  // method to update the user's profile information
  Future<void> _updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // update the display name with the new values from text fields
        final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
        await user.updateDisplayName(fullName);
        await user.reload();
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } catch (e) {
        // if something goes wrong, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  // method to check if the user is an admin
  Future<void> _checkIfAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // check the user’s role
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()?['role'] == 'admin') {
        setState(() {
          // if the user is an admin, set _isAdmin to true
          _isAdmin = true;
        });
      }
    }
  }

  // method to log the user out and navigate back to the auth screen
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'No Email';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[800],
                child: Text(
                  _firstNameController.text.isNotEmpty ? _firstNameController.text[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),

              // user info card
              Card(
                color: Colors.grey[900],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Name Surname', style: TextStyle(color: Colors.grey[400])),
                      _isEditing
                      // show text fields when editing
                          ? Row(
                        children: [
                          Expanded(
                            child: TextField(controller: _firstNameController, style: const TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(controller: _lastNameController, style: const TextStyle(color: Colors.white)),
                          ),
                        ],
                      )
                      // otherwise, just display the user's name
                          : Text('${_firstNameController.text} ${_lastNameController.text}', style: const TextStyle(fontSize: 20, color: Colors.white)),
                      const SizedBox(height: 10),
                      Text('Email', style: TextStyle(color: Colors.grey[400])),
                      Text(email, style: const TextStyle(fontSize: 16, color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // show save button when editing or show edit button
              _isEditing
                  ? ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _updateProfile,
                child: const Text('Save', style: TextStyle(color: Colors.white)),
              )
                  : ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                onPressed: () => setState(() => _isEditing = true),
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
              ),
              // if the user is an admin, show the admin panel button
              if (_isAdmin) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminPanel()),
                    );
                  },
                  child: const Text('Admin panel', style: TextStyle(color: Colors.white)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
