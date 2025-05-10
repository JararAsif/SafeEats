import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();

  bool _isSaving = false;
  String userId = "";

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });

      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          _nameController.text = userDoc['username'] ?? "";
          _allergiesController.text =
              (userDoc['allergies'] as List<dynamic>?)?.join(', ') ?? "";
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    String newName = _nameController.text.trim();
    String newPassword = _passwordController.text.trim();
    String newAllergies = _allergiesController.text.trim();

    setState(() {
      _isSaving = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Map<String, dynamic> updateData = {};

        // **Update Firestore Fields**
        if (newName.isNotEmpty) updateData['username'] = newName;
        if (newAllergies.isNotEmpty) {
          updateData['allergies'] = newAllergies.split(',').map((e) => e.trim()).toList();
        }

        if (updateData.isNotEmpty) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update(updateData);
        }

        // **Re-authenticate Before Password Update**
        if (newPassword.isNotEmpty) {
          bool reauthenticated = await _reauthenticateUser(user);
          if (!reauthenticated) return;

          // **Update FirebaseAuth Password**
          await user.updatePassword(newPassword);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  /// 🔹 **Re-authenticate User Before Password Update**
  Future<bool> _reauthenticateUser(User user) async {
    bool success = false;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Re-authenticate"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter your current password to continue:"),
              TextField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Current Password"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  AuthCredential credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: _currentPasswordController.text.trim(),
                  );
                  await user.reauthenticateWithCredential(credential);
                  success = true;
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Re-authentication failed. Incorrect password.")),
                  );
                }
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );

    return success;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _allergiesController,
              decoration: const InputDecoration(
                labelText: 'Allergies (comma-separated)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save Changes', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
