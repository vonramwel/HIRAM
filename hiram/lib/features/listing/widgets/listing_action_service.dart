// listing_action_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../common_widgets/confirmation_dialog.dart';
import '../../transaction/service/transaction_service.dart'; // Import TransactionService

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
      bool canProceed = await _checkTransactionsAndHandle(context, listingId);

      if (canProceed) {
        _updateVisibility(
          context: context,
          listingId: listingId,
          status: action == 'archive' ? 'archived' : 'deleted',
          onVisibilityUpdated: onVisibilityUpdated,
        );
      }
    }
  }

  static Future<bool> _checkTransactionsAndHandle(
      BuildContext context, String listingId) async {
    try {
      QuerySnapshot transactionSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('listingId', isEqualTo: listingId)
          .get();

      if (transactionSnapshot.docs.isEmpty) {
        // No transactions tied to the listing
        return true;
      }

      bool hasActiveTransaction = false;
      List<String> pendingTransactionIds = [];

      for (var doc in transactionSnapshot.docs) {
        String status = doc['status'] ?? '';
        if (status == 'Approved' || status == 'Lent') {
          hasActiveTransaction = true;
          break;
        } else if (status == 'Pending') {
          pendingTransactionIds.add(doc.id);
        }
      }

      if (hasActiveTransaction) {
        // Block deletion/archive
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cannot archive or delete this listing because there are active transactions.',
            ),
          ),
        );
        return false;
      }

      // Cancel all pending transactions
      for (String transactionId in pendingTransactionIds) {
        await FirebaseFirestore.instance
            .collection('transactions')
            .doc(transactionId)
            .update({'status': 'Cancelled'});
      }

      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
      return false;
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
