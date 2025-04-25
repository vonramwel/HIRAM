// lib/user/pages/otheruser_profile.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../listing/model/listing_model.dart';
import '../../listing/widgets/listing_card.dart';
import '../../inbox/presentation/chat_page.dart';
import '../../user_profile/service/userprofile_service.dart';

class OtherUserProfilePage extends StatefulWidget {
  final String userId;
  const OtherUserProfilePage({super.key, required this.userId});

  @override
  State<OtherUserProfilePage> createState() => _OtherUserProfilePageState();
}

class _OtherUserProfilePageState extends State<OtherUserProfilePage> {
  final userProfileService = UserProfileService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _userName = 'Loading...';
  String _phone = '';
  String _address = '';
  String _bio = '';
  String _profileImageUrl = '';
  List<Listing> _topListings = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Get user info
      final DocumentSnapshot snapshot =
          await _firestore.collection('User').doc(widget.userId).get();
      final userData = snapshot.data() as Map<String, dynamic>?;

      // Get listings
      final listings =
          await userProfileService.getListingsByUserId(widget.userId);

      if (userData != null && mounted) {
        setState(() {
          _userName = userData['name'] ?? 'Unknown User';
          _phone = userData['contactNumber'] ?? '';
          _address = userData['address'] ?? '';
          _bio = userData['bio'] ?? '';
          _profileImageUrl = userData['imgUrl'] ?? '';
          _topListings = listings
              .map<Listing>((data) => Listing.fromMap(data))
              .take(2)
              .toList();
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Seller Profile'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    receiverId: widget.userId,
                    receiverName: _userName,
                  ),
                ),
              );
            },
            child: const Text(
              "Contact Seller",
              style: TextStyle(color: Colors.white),
            ),
          )
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
              Text(_userName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
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
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Top Listings",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Column(
                children: _topListings
                    .map((listing) => ListingCard(listing: listing))
                    .toList(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
