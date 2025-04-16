import 'package:flutter/material.dart';

class GenerateCodeDialog {
  static void show(BuildContext context, String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Code Generated"),
        content: Text("Transaction code: $code"),
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
