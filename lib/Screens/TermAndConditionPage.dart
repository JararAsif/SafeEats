import 'package:flutter/material.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Terms & Conditions'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title
              const Text(
                "Terms & Conditions",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
              ),
              const SizedBox(height: 10),
              const Text(
                "Effective Date: March 2025",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
              const Divider(thickness: 1, height: 20),
              const Text(
                "By using this application, you agree to comply with the following terms and conditions. Failure to do so may result in suspension or termination of your account.",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 20),

              /// Section 1: User Responsibilities
              _sectionTitle("1. User Responsibilities"),
              _sectionText("As a user, you are expected to:"),
              _bulletPoint("Provide accurate and up-to-date information during registration."),
              _bulletPoint("Use the app in compliance with legal regulations."),
              _bulletPoint("Respect the rights and privacy of other users."),
              _bulletPoint("Report any suspicious activity to the support team."),
              const SizedBox(height: 15),

              /// Section 2: Prohibited Activities
              _sectionTitle("2. Prohibited Activities"),
              _sectionText("Users are strictly prohibited from engaging in:"),
              _bulletPoint("Spamming, phishing, or spreading malicious content."),
              _bulletPoint("Harassing, abusing, or threatening others."),
              _bulletPoint("Attempting to hack, exploit, or manipulate the platform."),
              _bulletPoint("Sharing misleading or false information."),
              const SizedBox(height: 15),







              /// Extra spacing for better scrolling
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
