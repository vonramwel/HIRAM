// lib/transaction/presentation/report_transaction_dialog.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/report_transaction_service.dart';

class ReportTransactionDialog extends StatefulWidget {
  final String transactionId;

  const ReportTransactionDialog({super.key, required this.transactionId});

  @override
  _ReportTransactionDialogState createState() =>
      _ReportTransactionDialogState();
}

class _ReportTransactionDialogState extends State<ReportTransactionDialog> {
  final TextEditingController _reasonController = TextEditingController();

  Future<void> _reportTransaction() async {
    String reason = _reasonController.text.trim();

    if (reason.isEmpty) {
      return; // Do not submit if no reason is entered.
    }

    try {
      await ReportTransactionService().reportTransaction(
        transactionId: widget.transactionId,
        reason: reason,
      );
      Navigator.pop(context); // Close the dialog after submitting.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction reported successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to report transaction')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report Transaction'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _reasonController,
            decoration: const InputDecoration(hintText: 'Enter your reason'),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _reportTransaction,
          child: const Text('Submit Report'),
        ),
      ],
    );
  }
}
