import 'package:flutter/material.dart';
import '../../transaction/model/transaction_model.dart';
import '../model/review_model.dart';
import '../service/review_service.dart'; // ✅ Added this line
import '../../auth/service/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewScreen extends StatefulWidget {
  final TransactionModel transaction;

  const ReviewScreen({super.key, required this.transaction});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 0;
  bool _isSubmitting = false;

  void _submitReview() async {
    if (_rating == 0 || _commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final currentUserId = await AuthMethods().getCurrentUserId();
    final isRenter = currentUserId == widget.transaction.renterId;
    final isLender = currentUserId == widget.transaction.ownerId;

    final review = ReviewModel(
      renterId: widget.transaction.renterId,
      lenderId: widget.transaction.ownerId,
      date: DateTime.now(),
      rating: _rating,
      comment: _commentController.text,
      reviewedBy: isRenter ? 'renter' : 'lender',
    );

    // ✅ Save the review to Firestore using the service
    final reviewService = ReviewService();
    await reviewService.submitReview(review);

    // ✅ Update the appropriate flag in Firestore
    final transactionRef = FirebaseFirestore.instance
        .collection('transactions')
        .doc(widget.transaction.transactionId);

    await transactionRef.update({
      if (isRenter) 'hasReviewedByRenter': true,
      if (isLender) 'hasReviewedByLender': true,
    });

    setState(() {
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review submitted successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Write a Review')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction ID: ${widget.transaction.transactionId}',
            ),
            const SizedBox(height: 10),
            const Text('Rate the transaction:'),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    _rating > index ? Icons.star : Icons.star_border,
                    color: _rating > index ? Colors.yellow : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Comments',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
