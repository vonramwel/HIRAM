// lib/user/pages/otheruser_listings_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../listing/model/listing_model.dart';
import '../../listing/widgets/listing_card.dart';
import '../service/userprofile_service.dart';

class OtherUserListingsPage extends StatefulWidget {
  final String userId;
  final String userName;

  const OtherUserListingsPage({
    Key? key,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  State<OtherUserListingsPage> createState() => _OtherUserListingsPageState();
}

class _OtherUserListingsPageState extends State<OtherUserListingsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, String> preloadedUserNames = {}; // Cache for user names

  Future<void> preloadUserNames(List<Listing> listings) async {
    final uniqueUserIds = listings.map((l) => l.userId).toSet();

    for (String userId in uniqueUserIds) {
      if (!preloadedUserNames.containsKey(userId)) {
        final userDoc = await _firestore.collection('User').doc(userId).get();
        if (userDoc.exists) {
          preloadedUserNames[userId] =
              userDoc.data()?['name'] ?? 'Unknown User';
        } else {
          preloadedUserNames[userId] = 'Unknown User';
        }
      }
    }
    setState(() {}); // Refresh UI after preloading names
  }

  Stream<List<Listing>> getOtherUserListingsStream() {
    return _firestore
        .collection('listings')
        .where('userId', isEqualTo: widget.userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Listing.fromMap(doc.data() as Map<String, dynamic>))
          .where((listing) =>
              listing.visibility != 'archived' &&
              listing.visibility != 'deleted')
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.userName}'s Listings"),
      ),
      body: StreamBuilder<List<Listing>>(
        stream: getOtherUserListingsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No listings available.'));
          }

          final listings = snapshot.data!;

          preloadUserNames(listings); // preload usernames

          return ListView.builder(
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];
              final userName =
                  preloadedUserNames[listing.userId] ?? 'Loading...';

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListingCard(
                  listing: listing,
                  userName: userName,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
