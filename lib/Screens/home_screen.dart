import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'UploadImageScreen.dart';
import 'ProfileScreen.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String username = "User";
  String email = "";
  final TextEditingController _searchController = TextEditingController();

  static const Color primaryColor = Color(0xFFFFA726);
  static const Color backgroundColor = Color(0xFFFFF3E0);

  List<Map<String, String>> articles = [
    {
      "title": "AI Detecting Allergens in Food",
      "description": "AI improves food safety by detecting allergens in products.",
      "image": "assets/ai_icon.png",
      "url": "https://keepsmilin4abbie.org/food-allergy-awareness-the-role-of-ai-technology-in-saving-lives/",
    },
    {
      "title": "Robotic Scanner for Food Safety",
      "description": "AI-powered robots scan packaging to detect allergens.",
      "image": "assets/robot_icon.jpeg",
      "url": "https://www.mwes.com/let-robots-hygienically-handle-our-food-ensuring-safety-in-food-production/",
    },
    {
      "title": "Smartphone App for Allergy Detection",
      "description": "AI apps help users scan food labels for allergens.",
      "image": "assets/allergy_warning_app.png",
      "url": "https://www.who.int/health-topics/food-safety/",
    },
    {
      "title": "Food safety",
      "description": "Food safety, nutrition and food security are closely linked.",
      "image": "assets/food_allergy.jpeg",
      "url": "https://www.mayoclinic.org/diseases-conditions/food-allergy/symptoms-causes/syc-20355095",
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
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
        });
      }
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UploadImageScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw "Could not launch $url";
    }
  }

  void _searchArticles() {
    String query = _searchController.text.toLowerCase();

    if (query.isNotEmpty) {
      setState(() {
        articles.sort((a, b) {
          bool aMatches = a["title"]!.toLowerCase().contains(query);
          bool bMatches = b["title"]!.toLowerCase().contains(query);
          return aMatches == bMatches ? 0 : (aMatches ? -1 : 1);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope( // Prevent Back Navigation
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false, // Removes back button
          backgroundColor: primaryColor,
          title: Text("Welcome, $username!"),
          centerTitle: true,
          elevation: 0,
        ),
        body: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreetingCard(),
                const SizedBox(height: 16),
                _buildSearchBox(),
                const SizedBox(height: 24),
                const Text(
                  "Latest Articles",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...articles.map((article) => _buildArticleCard(
                  title: article["title"]!,
                  description: article["description"]!,
                  image: article["image"]!,
                  url: article["url"]!,
                )),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
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
            tabBackgroundColor: primaryColor,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            gap: 8,
            tabs: [
              GButton(icon: Icons.home, text: "Home"),
              GButton(icon: Icons.add_circle, text: "Upload"),
              GButton(icon: Icons.person, text: "Profile"),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              _onItemTapped(index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Stay informed, stay safe.",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  const Text("Your daily source for food safety insights.",
                      style: TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search articles...",
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _searchArticles,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Search", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildArticleCard({required String title, required String description, required String image, required String url}) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Ensure the image loads properly
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  image,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.image_not_supported, size: 70, color: Colors.grey);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(description, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }}

