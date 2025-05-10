import 'package:flutter/material.dart';

class FAQsPage extends StatelessWidget {
  const FAQsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('FAQs'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Frequently Asked Questions",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Find answers to common questions below.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView(
                children: const [
                  _FAQItem(
                    question: "How do I reset my password?",
                    answer: "Go to Settings, select 'Change Password', and follow the instructions.",
                  ),
                  _FAQItem(
                    question: "How do I update my profile information?",
                    answer: "Navigate to the Profile page, edit your details, and save changes.",
                  ),
                  _FAQItem(
                    question: "Is my personal data secure?",
                    answer: "Yes, we use industry-standard encryption and security protocols to protect your data.",
                  ),
                  _FAQItem(
                    question: "How do I contact customer support?",
                    answer: "Go to the 'Help & Support' section and select 'Contact Support'.",
                  ),
                  _FAQItem(
                    question: "Can I delete my account permanently?",
                    answer: "Yes, go to 'Settings' > 'Account' and select 'Delete Account'. Please note that this action is irreversible.",
                  ),
                  _FAQItem(
                    question: "Why am I not receiving notifications?",
                    answer: "Ensure that notifications are enabled in both the app settings and your device settings.",
                  ),
                  _FAQItem(
                    question: "How can I report a bug or issue?",
                    answer: "Use the 'Contact Support' option to report any technical issues you encounter.",
                  ),
                  _FAQItem(
                    question: "Can I use the app on multiple devices?",
                    answer: "Yes, you can log in to your account from multiple devices, but ensure that you sign out from unused devices for security.",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FAQItem({required this.question, required this.answer, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        iconColor: Colors.orange,
        collapsedIconColor: Colors.orange,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(answer, style: const TextStyle(fontSize: 14, color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
