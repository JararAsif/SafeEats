import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'EditProfileScreen.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = "Loading...";
  String email = "Loading...";
  List<String> allergies = [];
  int _selectedIndex = 2;
  bool isLoading = true; // Track loading state

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      isLoading = true;
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          username = userDoc['username'] ?? "Unknown User";
          email = userDoc['email'] ?? "No Email Provided";

          // Convert allergies to a list
          var allergiesData = userDoc['allergies'];
          if (allergiesData is String) {
            allergies = allergiesData.split(',').map((e) => e.trim()).toList();
          } else if (allergiesData is List) {
            allergies = List<String>.from(allergiesData);
          } else {
            allergies = [];
          }

          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching profile: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/uploadImage');
        break;
      case 2:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          title: const Text('Profile'),
          centerTitle: true,
          elevation: 0,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          children: [
            _buildProfileHeader(),
            _buildAllergySection(), // Allergy Section
            const Divider(),
            _profileOption('Detection History', Icons.history, context, '/detectionHistory'),
            _profileOption('Add Picture', Icons.add_a_photo, context, '/uploadImage'),
            _profileOption('Feedback', Icons.feedback_outlined, context, '/feedback'),
            _profileOption('Help & Support', Icons.help_outline, context, '/helpSupport'),
            const Divider(),
            _signOutOption(context),
          ],
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  /// **🔹 Profile Header Section**
  Widget _buildProfileHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFFFA726)], // Orange gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4), // Adds depth
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                email,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final updatedProfile = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );

                  if (updatedProfile != null) {
                    _fetchUserProfile(); // Refresh data after editing
                  }
                },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text("Edit Profile"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 45,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 45, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildAllergySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 10),
              Text(
                "Allergy Information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          allergies.isNotEmpty
              ? Wrap(
            spacing: 8.0,
            runSpacing: 6.0,
            children: allergies
                .map((allergy) => Chip(
              label: Text(
                allergy,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.orange[100],
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ))
                .toList(),
          )
              : const Center(
            child: Text(
              "No allergies specified",
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// **🔹 Profile Option List Tiles**
  Widget _profileOption(String title, IconData icon, BuildContext context, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }

  /// **🔹 Sign Out Option**
  Widget _signOutOption(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.orange),
      title: const Text('Sign Out'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
      onTap: () async {
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacementNamed(context, '/signing');
      },
    );
  }

  /// **🔹 Modern Bottom Navigation Bar**
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: GNav(
        backgroundColor: Colors.white,
        color: Colors.black87,
        activeColor: Colors.white,
        tabBackgroundColor: const Color(0xFFFFA726),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        gap: 8,
        tabs: const [
          GButton(icon: Icons.home, text: "Home"),
          GButton(icon: Icons.add_circle, text: "Upload"),
          GButton(icon: Icons.person, text: "Profile"),
        ],
        selectedIndex: _selectedIndex,
        onTabChange: (index) => _onItemTapped(index),
      ),
    );
  }
}
