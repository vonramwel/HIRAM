// listing_action_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../common_widgets/confirmation_dialog.dart';

class ListingActionService {
  static Future<void> handleAction({
    required BuildContext context,
    required String listingId,
    required String action,
    required Function(String) onVisibilityUpdated,
  }) async {
    String title = action == 'archive' ? 'Archive Listing' : 'Delete Listing';
    String content = action == 'archive'
        ? 'Are you sure you want to archive this listing?'
        : 'Are you sure you want to delete this listing?';

    bool confirmed = await ConfirmationDialog.show(
      context,
      title: title,
      content: content,
      confirmText: action == 'archive' ? 'Archive' : 'Delete',
    );

    if (confirmed) {
      _updateVisibility(
        context: context,
        listingId: listingId,
        status: action == 'archive' ? 'archived' : 'deleted',
        onVisibilityUpdated: onVisibilityUpdated,
      );
    }
  }

  static Future<void> _updateVisibility({
    required BuildContext context,
    required String listingId,
    required String status,
    required Function(String) onVisibilityUpdated,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('listings')
          .doc(listingId)
          .update({'visibility': status});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Listing ${status == 'archived' ? 'archived' : 'deleted'} successfully',
          ),
        ),
      );

      onVisibilityUpdated(status);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update listing')),
      );
    }
  }
}
