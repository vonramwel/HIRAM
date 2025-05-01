import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FreezeActions {
  static Future<void> performFreezeOrUnfreeze({
    required String userId,
    required BuildContext context,
    required String action, // 'freeze' or 'unfreeze' (lowercase expected)
  }) async {
    final normalizedAction = action.toLowerCase().trim();
    final isFreeze = normalizedAction == 'freeze';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm ${isFreeze ? 'Freeze' : 'Unfreeze'}'),
        content: Text(isFreeze
            ? 'Are you sure you want to freeze this user\'s account? All their active listings will be hidden.'
            : 'Are you sure you want to unfreeze this user\'s account? All their hidden listings will be made public.'),
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

      // Update user account status
      await firestore.collection('User').doc(userId).update({
        'accountStatus': isFreeze ? 'locked' : 'normal',
      });

      // Get user listings
      final listings = await firestore
          .collection('listings')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in listings.docs) {
        final data = doc.data();
        final visibility = data['visibility'] as String?;

        if (isFreeze) {
          if (visibility == null || visibility == 'public') {
            batch.update(doc.reference, {'visibility': 'hidden'});
          }
        } else {
          if (visibility == 'hidden') {
            batch.update(doc.reference, {'visibility': 'public'});
          }
        }
      }
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isFreeze
              ? 'User account has been frozen and listings hidden.'
              : 'User account has been unfrozen and listings made public.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to process action.')),
      );
    }
  }
}
