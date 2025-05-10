import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Privacy Policy",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
              ),
              const SizedBox(height: 10),
              const Text(
                "Last Updated: March 2025",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
              const Divider(thickness: 1, height: 20),
              const Text(
                "We value your privacy and are committed to protecting your personal data. This privacy policy explains how we collect, use, and safeguard your information.",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 20),

              /// Section 1: Data Collection
              _sectionTitle("1. Data Collection"),
              _sectionText("We collect personal information to improve your experience, including:"),
              _bulletPoint("Name, email address, and contact details."),
              _bulletPoint("Profile preferences and settings."),
              _bulletPoint("Usage data and interactions within the app."),
              const SizedBox(height: 15),

              /// Section 2: How We Use Your Data
              _sectionTitle("2. How We Use Your Data"),
              _bulletPoint("To provide and improve our services."),
              _bulletPoint("To personalize your experience."),
              _bulletPoint("To enhance app security and detect fraud."),
              _bulletPoint("To comply with legal requirements."),
              const SizedBox(height: 15),

              /// Section 3: Data Security
              _sectionTitle("3. Data Security"),
              _sectionText(
                  "We implement industry-standard security measures, including encryption and secure storage, to protect your data from unauthorized access."),
              const SizedBox(height: 15),

              /// Section 4: Third-Party Sharing
              _sectionTitle("4. Third-Party Sharing"),
              _sectionText("We do not share your personal data with third parties unless:"),
              _bulletPoint("You provide explicit consent."),

              const SizedBox(height: 11),




              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contact Support coming soon!')),
                  );
                },
                child: const Text("Contact Support"),
              ),

              /// Add some extra spacing to ensure better scrolling experience
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _sectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
