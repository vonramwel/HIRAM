import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatPage({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final String chatId;
  String? receiverUserType;

  @override
  void initState() {
    super.initState();
    chatId = getChatId(currentUser.uid, widget.receiverId);
    fetchReceiverUserType();
  }

  String getChatId(String user1, String user2) {
    final sortedIds = [user1, user2]..sort();
    return sortedIds.join('_');
  }

  Future<void> fetchReceiverUserType() async {
    final doc =
        await _firestore.collection('User').doc(widget.receiverId).get();
    final data = doc.data();
    if (data != null && mounted) {
      setState(() {
        receiverUserType = data['userType'];
      });
    }
  }

  void sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = {
      'senderId': currentUser.uid,
      'text': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    };

    final chatDoc = _firestore.collection('chats').doc(chatId);
    final chatExists = (await chatDoc.get()).exists;
    if (!chatExists) {
      await chatDoc.set({
        'participants': [currentUser.uid, widget.receiverId],
      });
    }

    await chatDoc.collection('messages').add(message);
    _messageController.clear();
  }

  String formatDateSeparator(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return DateFormat.yMMMd().format(date);
    }
  }

  Widget buildDateSeparator(String dateLabel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            dateLabel,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    final doc = await _firestore.collection('User').doc(userId).get();
    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.receiverName}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                String? lastDateLabel;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final messageData = message.data() as Map<String, dynamic>;
                    final senderId = messageData['senderId'];
                    final timestamp = messageData['timestamp'] as Timestamp?;
                    final isMe = senderId == currentUser.uid;
                    final isAlert = messageData.containsKey('isAlert') &&
                        messageData['isAlert'] == true;

                    final messageTime = timestamp?.toDate();
                    final timeString = messageTime != null
                        ? DateFormat.jm().format(messageTime)
                        : '';

                    final currentDateLabel =
                        timestamp != null ? formatDateSeparator(timestamp) : '';
                    final showDateSeparator = currentDateLabel != lastDateLabel;
                    lastDateLabel = currentDateLabel;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showDateSeparator)
                          buildDateSeparator(currentDateLabel),
                        FutureBuilder<Map<String, dynamic>?>(
                          future: fetchUserData(senderId),
                          builder: (context, userSnapshot) {
                            final userData = userSnapshot.data;
                            final senderIsAdmin =
                                userData?['userType'] == 'admin';
                            final senderName = senderIsAdmin
                                ? 'ADMIN'
                                : userData?['name'] ?? 'Unknown';
                            final profileImage = userData?['imgUrl'];

                            Color? backgroundColor;
                            Color textColor = Colors.black87;
                            BorderRadiusGeometry borderRadius =
                                BorderRadius.circular(16);
                            Icon? alertIcon;

                            if (isAlert) {
                              backgroundColor = Colors.red[400];
                              textColor = Colors.white;
                              alertIcon = const Icon(Icons.warning,
                                  color: Colors.white, size: 16);
                            } else if (senderIsAdmin && !isMe) {
                              backgroundColor = Colors.orange[200];
                            } else {
                              backgroundColor =
                                  isMe ? Colors.blueAccent : Colors.grey[200];
                              textColor = isMe ? Colors.white : Colors.black87;
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: isMe
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  if (!isMe)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: CircleAvatar(
                                        radius: 18,
                                        backgroundImage: profileImage != null &&
                                                profileImage.isNotEmpty
                                            ? NetworkImage(profileImage)
                                            : null,
                                        child: profileImage == null ||
                                                profileImage.isEmpty
                                            ? const Icon(Icons.person, size: 20)
                                            : null,
                                      ),
                                    ),
                                  Flexible(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 14),
                                        decoration: BoxDecoration(
                                          color: backgroundColor,
                                          borderRadius: BorderRadius.only(
                                            topLeft: const Radius.circular(16),
                                            topRight: const Radius.circular(16),
                                            bottomLeft:
                                                Radius.circular(isMe ? 16 : 0),
                                            bottomRight:
                                                Radius.circular(isMe ? 0 : 16),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (!isMe)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 4),
                                                child: Text(
                                                  senderName,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: textColor,
                                                  ),
                                                ),
                                              ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (alertIcon != null)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 4, top: 2),
                                                    child: alertIcon,
                                                  ),
                                                Expanded(
                                                  child: Text(
                                                    messageData['text'],
                                                    style: TextStyle(
                                                      color: textColor,
                                                      fontSize: 15,
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: Text(
                                                timeString,
                                                style: TextStyle(
                                                  color: textColor
                                                      .withOpacity(0.7),
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
