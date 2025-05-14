import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../transaction/model/transaction_model.dart';
import '../model/review_model.dart';
import '../../auth/service/auth.dart';
import '../../report/presentation/report_transaction.dart';

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
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    AuthMethods().getCurrentUserId().then((id) {
      setState(() {
        _currentUserId = id;
      });
    });
  }

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

    final isRenter = _currentUserId == widget.transaction.renterId;
    final isLender = _currentUserId == widget.transaction.ownerId;

    final newDocRef = FirebaseFirestore.instance.collection('Reviews').doc();
    final reviewId = newDocRef.id;

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

    // ✅ Update listing rating if reviewed by renter
    if (isRenter) {
      final listingRef = FirebaseFirestore.instance
          .collection('listings')
          .doc(widget.transaction.listingId);

      final listingSnap = await listingRef.get();
      if (listingSnap.exists) {
        final data = listingSnap.data();
        final currentRating = (data?['rating'] ?? 0).toDouble();
        final currentRatingCount = (data?['ratingCount'] ?? 0);

        final newRatingCount = currentRatingCount + 1;
        final newAverageRating =
            ((currentRating * currentRatingCount) + _rating) / newRatingCount;

        await listingRef.update({
          'rating': double.parse(newAverageRating.toStringAsFixed(2)),
          'ratingCount': newRatingCount,
        });
      }
    } else {
      // ✅ Update listing rating if reviewed by lender
      final lenderRef = FirebaseFirestore.instance
          .collection('User')
          .doc(widget.transaction.renterId);
      final lenderSnap = await lenderRef.get();

      if (lenderSnap.exists) {
        final lenderData = lenderSnap.data();
        final currentUserRating = (lenderData?['rating'] ?? 0).toDouble();
        final currentRatingCount = (lenderData?['ratingCount'] ?? 0);

        final newRatingCount = currentRatingCount + 1;
        final newAverageUserRating =
            ((currentUserRating * currentRatingCount) + _rating) /
                newRatingCount;

        await lenderRef.update({
          'rating': double.parse(newAverageUserRating.toStringAsFixed(2)),
          'ratingCount': newRatingCount,
        });
      }
      // ✅ Also update lender's rating in the users collection
    }

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
    if (_currentUserId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isRenter = _currentUserId == widget.transaction.renterId;
    final ratingLabel = isRenter ? 'Rate the product' : 'Rate the renter';

    return Scaffold(
      resizeToAvoidBottomInset: true, // allow keyboard to resize screen
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Review Transaction',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => ReportTransactionDialog(
                                  transactionId:
                                      widget.transaction.transactionId,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Report Transaction"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              _rating > index ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 32,
                            ),
                            onPressed: () {
                              setState(() {
                                _rating = index + 1;
                              });
                            },
                          );
                        }),
                      ),
                      Text(
                        ratingLabel,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Additional Notes',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Write your comment here...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                        maxLines: 5,
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedImages
                            .map((image) => ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(image.path),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: OutlinedButton(
                          onPressed:
                              _selectedImages.length >= 3 ? null : _pickImages,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Add Images (up to 3)',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
