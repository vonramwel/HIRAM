// lib/user/pages/otheruser_profile.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- NEW IMPORT
import '../../listing/model/listing_model.dart';
import '../../listing/widgets/listing_card.dart';
import '../../inbox/presentation/chat_page.dart';
import '../../user_profile/service/userprofile_service.dart';
import 'otheruser_listings_page.dart';
import '../../report/presentation/report_user.dart'; // <-- ALREADY IMPORTED

class OtherUserProfilePage extends StatefulWidget {
  final String userId;
  const OtherUserProfilePage({super.key, required this.userId});

  @override
  State<OtherUserProfilePage> createState() => _OtherUserProfilePageState();
}

class _OtherUserProfilePageState extends State<OtherUserProfilePage> {
  final userProfileService = UserProfileService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // <-- NEW

  String _userName = 'Loading...';
  String _phone = '';
  String _address = '';
  String _bio = '';
  String _profileImageUrl = '';
  String? _currentUserType; // <-- NEW

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCurrentUserType(); // <-- NEW
  }

  Future<void> _loadUserData() async {
    try {
      final DocumentSnapshot snapshot =
          await _firestore.collection('User').doc(widget.userId).get();
      final userData = snapshot.data() as Map<String, dynamic>?;

      if (userData != null && mounted) {
        setState(() {
          _userName = userData['name'] ?? 'Unknown User';
          _phone = userData['contactNumber'] ?? '';
          _address = userData['address'] ?? '';
          _bio = userData['bio'] ?? '';
          _profileImageUrl = userData['imgUrl'] ?? '';
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadCurrentUserType() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final DocumentSnapshot snapshot =
            await _firestore.collection('User').doc(currentUser.uid).get();
        final userData = snapshot.data() as Map<String, dynamic>?;
        if (userData != null && mounted) {
          setState(() {
            _currentUserType = userData['userType'];
          });
        }
      }
    } catch (e) {
      print('Error loading current user type: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Seller Profile'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'contact') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      receiverId: widget.userId,
                      receiverName: _userName,
                    ),
                  ),
                );
              } else if (value == 'report') {
                showDialog(
                  context: context,
                  builder: (context) => ReportUserDialog(userId: widget.userId),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'contact',
                child: Text('Contact Seller'),
              ),
              if (_currentUserType != 'admin') // <-- ONLY show if NOT admin
                const PopupMenuItem(
                  value: 'report',
                  child: Text('Report User'),
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: _profileImageUrl.isNotEmpty
                    ? NetworkImage(_profileImageUrl)
                    : null,
                child: _profileImageUrl.isEmpty
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 10),
              Text(
                _userName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_phone.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(_phone, style: const TextStyle(color: Colors.black54)),
              ],
              if (_address.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(_address, style: const TextStyle(color: Colors.black45)),
              ],
              const SizedBox(height: 10),
              TextField(
                controller: TextEditingController(text: _bio),
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Add Bio...',
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Top Listings",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OtherUserListingsPage(
                            userId: widget.userId,
                            userName: _userName,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'VIEW ALL LISTINGS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('listings')
                    .where('userId', isEqualTo: widget.userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No listings available.'));
                  }

                  final listings = snapshot.data!.docs
                      .map((doc) =>
                          Listing.fromMap(doc.data() as Map<String, dynamic>))
                      .where((listing) =>
                          listing.visibility != 'archived' &&
                          listing.visibility != 'deleted')
                      .take(2)
                      .toList();

                  if (listings.isEmpty) {
                    return const Center(child: Text('No listings available.'));
                  }

                  return Column(
                    children: listings
                        .map((listing) => ListingCard(
                              listing: listing,
                              userName: _userName,
                            ))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
