import 'package:flutter/material.dart';
import '../service/transaction_service.dart';

class InputCodeDialog {
  static void show({
    required BuildContext context,
    required String transactionId,
    required String status,
    required Future<void> Function(String newStatus) updateStatusCallback,
  }) {
    final TextEditingController codeController = TextEditingController();
    final TransactionService _transactionService = TransactionService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter Transaction Code"),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(hintText: "Enter 6-digit code"),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              bool isValid = await _transactionService.validateTransactionCode(
                transactionId,
                codeController.text,
                status,
              );

              if (isValid && status == "Approved") {
                await updateStatusCallback("Lent");
                Navigator.pop(context);
                _showResultDialog(
                    context, "Transaction has been marked as Lent.");
              } else if (isValid && status == "Lent") {
                await updateStatusCallback("Completed");
                Navigator.pop(context);
                _showResultDialog(
                    context, "Transaction has been marked as Completed.");
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Invalid code. Please try again.")),
                );
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  static void _showResultDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Success"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
