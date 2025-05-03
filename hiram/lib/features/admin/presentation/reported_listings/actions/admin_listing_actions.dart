// lib/reported_listing/admin_listing_actions.dart
import 'package:flutter/material.dart';
import '../../../../listing/model/listing_model.dart';
import 'alert_listing.dart';

class AdminListingActions {
  static void showAlert({
    required BuildContext context,
    required String receiverId,
    required Listing listing,
    required String reason,
  }) {
    AlertListing.showAlertDialog(
      context: context,
      receiverId: receiverId,
      listing: listing,
      reason: reason,
    );
  }

  static void hideListing(BuildContext context, String listingId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Listing $listingId is now hidden.')),
    );
  }

  static void deleteListing(BuildContext context, String listingId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this listing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Placeholder for delete logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Listing $listingId deleted.')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
