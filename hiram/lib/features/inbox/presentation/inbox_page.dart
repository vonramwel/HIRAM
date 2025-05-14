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

    final List<Map<String, dynamic>> conversations = [];

    for (var doc in snapshot.docs) {
      final chatId = doc.id;
      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (messagesSnapshot.docs.isEmpty) continue;

      final lastMessageDoc = messagesSnapshot.docs.first;
      final lastMessage = lastMessageDoc.data();
      final isAlert = lastMessage['isAlert'] == true;

      final seenBy = List<String>.from(lastMessage['seenBy'] ?? []);
      final isUnread = !seenBy.contains(currentUser.uid);

      final userIds = chatId.split('_');
      final otherUserId =
          userIds.firstWhere((id) => id != currentUser.uid, orElse: () => '');

      if (otherUserId.isEmpty) continue;

      final userData = await fetchUserData(otherUserId);
      if (userData == null) continue;

      final userType = userData['userType'] ?? 'user';
      final name =
          userType == 'admin' ? 'ADMIN' : userData['name'] ?? 'Unknown';

      conversations.add({
        'chatId': chatId,
        'otherUserId': otherUserId,
        'name': name,
        'imgUrl': userData['imgUrl'],
        'userType': userType,
        'lastMessage': lastMessage['text'] ?? '',
        'timestamp': lastMessage['timestamp'],
        'isAlert': isAlert,
        'isUnread': isUnread,
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
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return DateFormat.jm().format(date);
    } else {
      return DateFormat.MMMd().format(date);
    }
  }

  Future<void> markLastMessageAsRead(String chatId) async {
    final lastMsgSnapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (lastMsgSnapshot.docs.isNotEmpty) {
      final docId = lastMsgSnapshot.docs.first.id;
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(docId)
          .update({
        'seenBy': FieldValue.arrayUnion([currentUser.uid])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchConversations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final conversations = snapshot.data ?? [];

          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    "No conversations yet",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView.separated(
              itemCount: conversations.length,
              separatorBuilder: (context, index) => const Divider(height: 0),
              itemBuilder: (context, index) {
                final convo = conversations[index];
                final imgUrl = convo['imgUrl'] as String?;
                final name = convo['name'];
                final lastMessage = convo['lastMessage'];
                final time = formatTime(convo['timestamp']);
                final isAlert = convo['isAlert'] == true;
                final isUnread = convo['isUnread'] == true;
                final userType = convo['userType'];
                final isAdmin = userType == 'admin';

                return InkWell(
                  onTap: () async {
                    await markLastMessageAsRead(convo['chatId']);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          receiverId: convo['otherUserId'],
                          receiverName: name,
                        ),
                      ),
                    ).then((_) => setState(() {})); // Refresh on return
                  },
                  child: Container(
                    color: isAdmin ? Colors.blue.shade50 : Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: imgUrl != null && imgUrl.isNotEmpty
                              ? NetworkImage(imgUrl)
                              : null,
                          child: imgUrl == null || imgUrl.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontWeight: isAdmin
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        fontSize: 16,
                                        color: isAdmin
                                            ? Colors.blue.shade900
                                            : Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    time,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      isAlert
                                          ? '[ALERT] $lastMessage'
                                          : lastMessage,
                                      style: TextStyle(
                                        fontWeight: isAlert || isUnread
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isAlert
                                            ? Colors.red
                                            : isUnread
                                                ? Colors.black
                                                : Colors.grey.shade700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isUnread)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 6.0),
                                      child: Icon(Icons.circle,
                                          color: Colors.blue, size: 10),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (isAdmin)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(Icons.verified_user,
                                size: 18, color: Colors.blue),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
