// lib/user/pages/mylistings_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../listing/model/listing_model.dart';
import '../../listing/widgets/listing_card.dart';
import '../service/userprofile_service.dart';

class MyListingsPage extends StatefulWidget {
  const MyListingsPage({super.key});

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
  final UserProfileService _userProfileService = UserProfileService();
  final Map<String, String> preloadedUserNames = {}; // Cache for user names

  Future<void> preloadUserNames(List<Listing> listings) async {
    final uniqueUserIds = listings.map((l) => l.userId).toSet();

    for (String userId in uniqueUserIds) {
      if (!preloadedUserNames.containsKey(userId)) {
        final userDoc = await FirebaseFirestore.instance
            .collection('User')
            .doc(userId)
            .get();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Listings"),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _userProfileService.streamCurrentUserListings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("You have no listings yet."));
          }

          final listings =
              snapshot.data!.map((data) => Listing.fromMap(data)).toList();

          // Preload usernames
          preloadUserNames(listings);

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
