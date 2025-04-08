import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/review_model.dart';

class ReviewService {
  final CollectionReference _reviewCollection =
      FirebaseFirestore.instance.collection('Reviews');

  Future<void> submitReview(ReviewModel review) async {
    await _reviewCollection.add(review.toMap());
  }
}
