import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../listing/model/listing_model.dart';
import 'alert_listing.dart';

class DeleteListingHandler {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> deleteListing({
    required BuildContext context,
    required Listing listing,
    required String listingId,
    required String ownerId,
    required String reason,
  }) async {
    // Update listing visibility to 'deleted'
    await _firestore.collection('listings').doc(listingId).update({
      'visibility': 'deleted',
    });

    // Cancel all pending transactions
    await _cancelPendingTransactions(listingId);

    // Send alert to the owner
    await AlertListing.sendAlertDirectly(
      receiverId: ownerId,
      listing: listing,
      reason: reason,
      isDeleted: true,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Listing "${listing.title}" has been marked as deleted.'),
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
