import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../transaction/model/transaction_model.dart';
import '../model/review_model.dart';
import '../../auth/service/auth.dart';

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
  List<XFile> _selectedImages = [];

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.length > 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only upload up to 3 images.')),
      );
      return;
    }

    setState(() {
      _selectedImages = images;
    });
  }

  Future<List<String>> _uploadImages(String reviewId) async {
    List<String> downloadUrls = [];
    for (int i = 0; i < _selectedImages.length; i++) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('review_images/$reviewId/image_$i.jpg');
      await ref.putFile(File(_selectedImages[i].path));
      final url = await ref.getDownloadURL();
      downloadUrls.add(url);
    }
    return downloadUrls;
  }

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

    // Create a new review document reference
    final newDocRef = FirebaseFirestore.instance.collection('Reviews').doc();
    final reviewId = newDocRef.id;

    // Upload images and get URLs
    final imageUrls = await _uploadImages(reviewId);

    final review = ReviewModel(
      renterId: widget.transaction.renterId,
      lenderId: widget.transaction.ownerId,
      date: DateTime.now(),
      rating: _rating,
      comment: _commentController.text,
      reviewedBy: isRenter ? 'renter' : 'lender',
      transactionId: widget.transaction.transactionId,
      listingId: widget.transaction.listingId,
      imageUrls: imageUrls,
    );

    await newDocRef.set(review.toMap());

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Transaction ID: ${widget.transaction.transactionId}'),
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
              const Text('Attach up to 3 images (optional):'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedImages
                    .map((image) => Image.file(
                          File(image.path),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ))
                    .toList(),
              ),
              TextButton.icon(
                onPressed:
                    _selectedImages.length >= 3 ? null : () => _pickImages(),
                icon: const Icon(Icons.image),
                label: const Text('Pick Images'),
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
      ),
    );
  }
}
