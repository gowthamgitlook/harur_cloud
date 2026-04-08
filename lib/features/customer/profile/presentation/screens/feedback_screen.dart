import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/custom_button.dart';
import '../../../../../shared/widgets/custom_text_field.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Feedback')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How was your experience?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Your feedback helps us improve Harur Cloud Kitchen.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            
            // Rating Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  iconSize: 48,
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: index < _rating ? Colors.amber : Colors.grey,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 32),
            
            CustomTextField(
              controller: _commentController,
              label: 'Your comments',
              hint: 'What did you like or what can we improve?',
              maxLines: 5,
            ),
            const SizedBox(height: 40),
            
            CustomButton(
              text: 'Submit Feedback',
              onPressed: _rating == 0 || _isSubmitting ? null : _submitFeedback,
              isLoading: _isSubmitting,
            ),
          ],
        ),
      ),
    );
  }

  void _submitFeedback() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your feedback!'), backgroundColor: AppColors.success),
      );
      Navigator.pop(context);
    }
  }
}
