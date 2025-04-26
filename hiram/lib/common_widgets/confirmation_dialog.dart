// confirmation_dialog.dart
import 'package:flutter/material.dart';

class ConfirmationDialog {
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: <Widget>[
                TextButton(
                  child: Text(cancelText),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                ElevatedButton(
                  child: Text(confirmText),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false; // returns false if dialog is dismissed
  }
}
