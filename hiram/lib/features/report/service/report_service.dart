import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportService {
  static Future<void> reportListing({
    required String listingId,
    required String reason,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await FirebaseFirestore.instance.collection('listing_reports').add({
      'listingId': listingId,
      'reportedBy': currentUser.uid,
      'reason': reason,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
