import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../listing/model/listing_model.dart';
import 'alert_listing.dart';

class HideListingHandler {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> toggleListingVisibility({
    required BuildContext context,
    required Listing listing,
    required String listingId,
    required String ownerId,
    required String reason,
  }) async {
    final currentVisibility = listing.visibility;
    final newVisibility = currentVisibility == 'hidden' ? 'visible' : 'hidden';

    // Update listing visibility
    await _firestore.collection('listings').doc(listingId).update({
      'visibility': newVisibility,
    });

    // If hiding, cancel pending transactions and send alert
    if (newVisibility == 'hidden') {
      await _cancelPendingTransactions(listingId);
      await AlertListing.sendAlertDirectly(
        receiverId: ownerId,
        listing: listing,
        reason: reason,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Listing "${listing.title}" is now ${newVisibility == 'hidden' ? "hidden" : "visible"}.',
        ),
      ),
    );
  }

  Future<void> _cancelPendingTransactions(String listingId) async {
    final query = await _firestore
        .collection('transactions')
        .where('listingId', isEqualTo: listingId)
        .where('status', isEqualTo: 'Pending')
        .get();

    for (final doc in query.docs) {
      await doc.reference.update({'status': 'Cancelled'});
    }
  }
}
