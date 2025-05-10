import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'home_screen.dart';
import 'ProfileScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';

class UploadImageScreen extends StatefulWidget {
  const UploadImageScreen({super.key});

  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  File? _image;
  int _selectedIndex = 1;
  String username = "";
  String email = "";
  List<String> userAllergies = [];
  late AudioPlayer _audioPlayer;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _fetchUserProfile();
    requestNotificationPermission();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        email = user.email ?? "";
      });
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          username = userDoc['username'] ?? "User";
          userAllergies = List<String>.from(userDoc['allergies'] ?? []);
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _getResults() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or capture an image first.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Processing image..."),
            ],
          ),
        );
      },
    );

    const String apiKey = 'uxG5rkclgzMj25LydYOG';
    const String modelEndpoint = 'safeeats-8ovwy/6';
    final String url = 'https://serverless.roboflow.com/$modelEndpoint?api_key=$apiKey';

    try {
      final bytes = await _image!.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: base64Image,
      );

      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = _parseResults(data);

        List<String> detectedAllergens = [];
        if (data['predictions'] != null && data['predictions'].isNotEmpty) {
          for (var prediction in data['predictions']) {
            String allergen = prediction['class']?.toString() ?? 'Unknown';
            detectedAllergens.add(allergen);
          }
        }

        List<String> matchingAllergies = detectedAllergens
            .where((allergen) => userAllergies.contains(allergen))
            .toList();

        await _storeResultsInFirestore(data);
        await _showResultDialog(result, matchingAllergies);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Detection completed!')),
        );
      } else {
        await _showResultDialog('Error: ${response.statusCode} - ${response.body}', []);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process image: ${response.statusCode}')),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      await _showResultDialog('Error: $e', []);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during Detection: $e')),
      );
    }
  }

  String _parseResults(Map<String, dynamic> data) {
    if (data['predictions'] == null || data['predictions'].isEmpty) {
      return 'No allergens detected.';
    }

    Map<String, List<double>> grouped = {};

    for (var prediction in data['predictions']) {
      String allergen = prediction['class'];
      double confidence = prediction['confidence'];
      if (!grouped.containsKey(allergen)) {
        grouped[allergen] = [];
      }
      grouped[allergen]!.add(confidence);
    }

    List<String> mergedResults = grouped.entries.map((entry) {
      double avgConfidence = entry.value.reduce((a, b) => a + b) / entry.value.length;
      return '${entry.key} (${(avgConfidence * 100).toStringAsFixed(1)}%)';
    }).toList();

    return 'Detected Allergens:\n${mergedResults.join('\n')}';
  }


  Future<void> _storeResultsInFirestore(Map<String, dynamic> data) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated. Cannot save results.')),
      );
      return;
    }

    final resultsCollection = FirebaseFirestore.instance.collection('Results');
    String sessionId = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      if (data['predictions'] == null || data['predictions'].isEmpty) {
        await resultsCollection.add({
          'Class': 'No allergens detected',
          'Confidence': 0,
          'userId': user.uid,
          'sessionId': sessionId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        Map<String, List<double>> grouped = {};

        for (var prediction in data['predictions']) {
          String allergen = prediction['class']?.toString() ?? 'Unknown';
          double confidence = (prediction['confidence'] as num?)?.toDouble() ?? 0.0;

          if (!grouped.containsKey(allergen)) {
            grouped[allergen] = [];
          }
          grouped[allergen]!.add(confidence);
        }

        for (var entry in grouped.entries) {
          double avgConfidence = entry.value.reduce((a, b) => a + b) / entry.value.length;
          await resultsCollection.add({
            'Class': entry.key,
            'Confidence': avgConfidence,
            'userId': user.uid,
            'sessionId': sessionId,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save results to Database: $e')),
      );
    }
  }


  Future<void> _showResultDialog(String result, List<String> matchingAllergies) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Detection Results',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.orange),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline, size: 40, color: Colors.orange),
              const SizedBox(height: 10),
              Text(
                result,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
          elevation: 8,
        );
      },
    );

    if (matchingAllergies.isNotEmpty) {
      _showAllergyAlert(matchingAllergies);
    }
  }

  void _showAllergyAlert(List<String> matchingAllergies) async {
    print('Showing allergy alert for: $matchingAllergies');
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));


    // Remove any existing overlay
    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (context) {
        print('Custom overlay widget built');
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Allergy Alert: ${matchingAllergies.join(', ')} detected!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        _overlayEntry?.remove();
                        _overlayEntry = null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Auto-dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: const Text('Upload Picture', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildImageCard(),
              const SizedBox(height: 30),
              _buildButton("Upload Image", Icons.image, () => _pickImage(ImageSource.gallery)),
              const SizedBox(height: 20),
              _buildButton("Take Picture", Icons.camera_alt, () => _pickImage(ImageSource.camera)),
              if (_image != null) ...[
                const SizedBox(height: 20),
                _buildButton("Get Results", Icons.check_circle, _getResults),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildImageCard() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: _image == null
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.image_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 10),
          Text("No image selected", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      )
          : ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _image!,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFA01F),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 50),
        elevation: 3,
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: GNav(
        backgroundColor: Colors.white,
        color: Colors.black87,
        activeColor: Colors.white,
        tabBackgroundColor: const Color(0xFFFF9800),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        gap: 8,
        tabs: const [
          GButton(icon: Icons.home, text: "Home"),
          GButton(icon: Icons.add_circle, text: "Upload"),
          GButton(icon: Icons.person, text: "Profile"),
        ],
        selectedIndex: _selectedIndex,
        onTabChange: (index) {
          _onItemTapped(index);
        },
      ),
    );
  }

  Future<void> requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;
    print('Notification permission status: $status');

    if (status.isDenied) {
      status = await Permission.notification.request();
      print('Notification permission after request: $status');
    }

    if (status.isPermanentlyDenied) {
      print('Notification permission permanently denied. Opening settings...');
      await openAppSettings();
    }
  }
}