import 'package:flutter/material.dart';
import 'FaqsPage.dart';
import 'ContactSupportPage.dart';
import 'PrivacyPolicyPage.dart';
import 'TermAndConditionPage.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Help & Support'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'We are here to help you!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 20),
            _supportOption(
              context,
              'FAQs',
              'Find answers to frequently asked questions.',
              Icons.question_answer_outlined,
              const FAQsPage(),
            ),
            const Divider(),
            _supportOption(
              context,
              'Contact Support',
              'Get in touch with our support team.',
              Icons.headset_mic_outlined,
              const ContactSupportPage(),
            ),
            const Divider(),
            _supportOption(
              context,
              'Privacy Policy',
              'Learn about our privacy practices.',
              Icons.privacy_tip_outlined,
              const PrivacyPolicyPage(),
            ),
            const Divider(),
            _supportOption(
              context,
              'Terms & Conditions',
              'Read our terms and conditions.',
              Icons.article_outlined,
              const TermsConditionsPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _supportOption(BuildContext context, String title, String subtitle, IconData icon, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}
