import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BanActions {
  static Future<void> performBan({
    required String userId,
    required BuildContext context,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Ban'),
        content: const Text(
            'Are you sure you want to ban this user? All their listings will be marked as deleted and pending transactions will be cancelled.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      // 1. Update user account status to "banned"
      final userRef = firestore.collection('User').doc(userId);
      batch.update(userRef, {'accountStatus': 'banned'});

      // 2. Mark all user listings as "deleted"
      final listings = await firestore
          .collection('listings')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in listings.docs) {
        batch.update(doc.reference, {'visibility': 'deleted'});
      }

      // 3. Cancel all pending transactions involving the user
      final transactions = await firestore
          .collection('transactions')
          .where('status', isEqualTo: 'Pending')
          .get();

      for (final doc in transactions.docs) {
        final data = doc.data();
        if (data['renterId'] == userId || data['ownerId'] == userId) {
          batch.update(doc.reference, {'status': 'Cancelled'});
        }
      }

      // Commit all batched operations
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'User has been banned. Listings removed and transactions cancelled.'),
        ),
      );
    } catch (e) {
      print('Error during ban: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to ban user.')),
      );
    }
  }
}
