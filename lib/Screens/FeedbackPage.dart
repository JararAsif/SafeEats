import 'package:flutter/material.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int safetyRating = 0;
  int communicationRating = 0;
  bool recommend = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave a Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Safety',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text('How safe is the app to use?'),
            _buildStarRating(
              rating: safetyRating,
              onChanged: (value) {
                setState(() {
                  safetyRating = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Communication',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text('How convenient is communication with the app?'),
            _buildStarRating(
              rating: communicationRating,
              onChanged: (value) {
                setState(() {
                  communicationRating = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Would you recommend the app?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.thumb_down,
                    color: !recommend ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      recommend = false;
                    });
                  },
                ),
                const SizedBox(width: 24),
                IconButton(
                  icon: Icon(
                    Icons.thumb_up,
                    color: recommend ? Colors.green : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      recommend = true;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Praise',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write your review here...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle submit logic here
                  Navigator.pop(context);
                },
                child: const Text('Submit Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating({required int rating, required Function(int) onChanged}) {
    return Row(
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.orange,
          ),
          onPressed: () => onChanged(index + 1),
        );
      }),
    );
  }
}
