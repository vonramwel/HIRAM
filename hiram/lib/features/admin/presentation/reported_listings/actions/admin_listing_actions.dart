import 'package:flutter/material.dart';
import '../../../../listing/model/listing_model.dart';
import 'alert_listing.dart';
import 'hide_listing.dart';
import 'delete_listing.dart';

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

  static void toggleHideListing({
    required BuildContext context,
    required Listing listing,
    required String listingId,
    required String ownerId,
    required String reason,
  }) {
    final handler = HideListingHandler();
    handler.toggleListingVisibility(
      context: context,
      listing: listing,
      listingId: listingId,
      ownerId: ownerId,
      reason: reason,
    );
  }

  static void deleteListing({
    required BuildContext context,
    required Listing listing,
    required String listingId,
    required String ownerId,
    required String reason,
  }) {
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
            onPressed: () async {
              Navigator.pop(context);
              final handler = DeleteListingHandler();
              await handler.deleteListing(
                context: context,
                listing: listing,
                listingId: listingId,
                ownerId: ownerId,
                reason: reason,
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
