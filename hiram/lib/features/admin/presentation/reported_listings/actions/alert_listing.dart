// lib/reported_listing/alert_listing.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../listing/model/listing_model.dart';

class AlertListing {
  static Future<void> showAlertDialog({
    required BuildContext context,
    required String receiverId,
    required Listing listing,
    required String reason,
  }) async {
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

    final defaultMessage =
        'Your listing titled "${listing.title}" was reported for the following reason: "$reason". Please take necessary action.';

    messageController.text = defaultMessage;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send Alert'),
          content: TextField(
            controller: messageController,
            maxLines: 5,
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

  static String _getChatId(String user1, String user2) {
    final sortedIds = [user1, user2]..sort();
    return sortedIds.join('_');
  }

  static Future<void> sendAlertDirectly({
    required String receiverId,
    required Listing listing,
    required String reason,
    bool isDeleted = false,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final senderId = currentUser.uid;
    final chatId = _getChatId(senderId, receiverId);

    final chatDoc = firestore.collection('chats').doc(chatId);
    final chatExists = (await chatDoc.get()).exists;

    if (!chatExists) {
      await chatDoc.set({
        'participants': [senderId, receiverId]
      });
    }

    final action = isDeleted ? 'deleted' : 'hidden';
    final messageText =
        'Your listing titled "${listing.title}" was reported for the following reason: "$reason". The listing has been $action by the Admin.';

    final message = {
      'senderId': senderId,
      'text': messageText,
      'timestamp': FieldValue.serverTimestamp(),
      'isAlert': true,
    };

    await chatDoc.collection('messages').add(message);
  }
}
