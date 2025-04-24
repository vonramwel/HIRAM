import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'chat_page.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String getChatId(String user1, String user2) {
    final sortedIds = [user1, user2]..sort();
    return sortedIds.join('_');
  }

  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    final doc = await _firestore.collection('User').doc(userId).get();
    return doc.data();
  }

  Future<List<Map<String, dynamic>>> fetchConversations() async {
    final snapshot = await _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUser.uid)
        .get();

    final chatIds = snapshot.docs.map((doc) => doc.id).toList();
    final List<Map<String, dynamic>> conversations = [];

    for (var chatId in chatIds) {
      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (messagesSnapshot.docs.isEmpty) continue;

      final lastMessage = messagesSnapshot.docs.first.data();
      final userIds = chatId.split('_');
      final otherUserId =
          userIds.firstWhere((id) => id != currentUser.uid, orElse: () => '');

      if (otherUserId.isEmpty) continue;

      final userData = await fetchUserData(otherUserId);
      if (userData == null) continue;

      conversations.add({
        'chatId': chatId,
        'otherUserId': otherUserId,
        'name': userData['name'] ?? 'Unknown',
        'imgUrl': userData['imgUrl'],
        'lastMessage': lastMessage['text'] ?? '',
        'timestamp': lastMessage['timestamp'],
      });
    }

    conversations.sort((a, b) {
      final tsA = (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime(1970);
      final tsB = (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime(1970);
      return tsB.compareTo(tsA);
    });

    return conversations;
  }

  String formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return DateFormat.jm().format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inbox')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchConversations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final conversations = snapshot.data ?? [];

          if (conversations.isEmpty) {
            return const Center(child: Text("No conversations yet."));
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final convo = conversations[index];
              final imgUrl = convo['imgUrl'] as String?;
              final name = convo['name'];
              final lastMessage = convo['lastMessage'];
              final time = formatTime(convo['timestamp']);

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: imgUrl != null && imgUrl.isNotEmpty
                      ? NetworkImage(imgUrl)
                      : null,
                  child: (imgUrl == null || imgUrl.isEmpty)
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(name),
                subtitle: Text(
                  lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  time,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        receiverId: convo['otherUserId'],
                        receiverName: name,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
