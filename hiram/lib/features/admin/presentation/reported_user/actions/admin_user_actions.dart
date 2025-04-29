import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'freeze.dart';

class AdminUserActions {
  static void showAlertDialog({
    required BuildContext context,
    required String receiverId,
    required String receiverName,
  }) {
    final TextEditingController messageController = TextEditingController();
    final currentUser = FirebaseAuth.instance.currentUser!;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    void sendAlertMessage(String messageText) async {
      final senderId = currentUser.uid;
      final chatId = _getChatId(senderId, receiverId);

      final chatDoc = firestore.collection('chats').doc(chatId);
      final chatExists = (await chatDoc.get()).exists;

      if (!chatExists) {
        await chatDoc.set({
          'participants': [senderId, receiverId]
        });
      }

      final message = {
        'senderId': senderId,
        'text': messageText,
        'timestamp': FieldValue.serverTimestamp(),
        'isAlert': true,
      };

      await chatDoc.collection('messages').add(message);
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send Alert'),
          content: TextField(
            controller: messageController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Enter message to send to the user',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final message = messageController.text.trim();
                if (message.isNotEmpty) {
                  sendAlertMessage(message);
                  Navigator.pop(context);
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> performFreezeOrUnfreezeAction({
    required String userId,
    required BuildContext context,
    required String action,
  }) async {
    final normalizedAction = action.toLowerCase().trim();
    if (normalizedAction != 'freeze' && normalizedAction != 'unfreeze') {
      print('Invalid action: $action');
      return;
    }

    await FreezeActions.performFreezeOrUnfreeze(
      userId: userId,
      context: context,
      action: normalizedAction,
    );
  }

  static void performBanAction() {
    print('Ban action executed');
  }

  static String _getChatId(String user1, String user2) {
    final sortedIds = [user1, user2]..sort();
    return sortedIds.join('_');
  }
}
