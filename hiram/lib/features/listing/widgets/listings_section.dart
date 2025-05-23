import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/listing_model.dart';
import '../service/listing_service.dart';
import '../../auth/service/auth.dart'; // Import AuthMethods for user authentication
import '../../listing/widgets/categories.dart';
import 'listing_card.dart'; // New import

class ListingsSection extends StatefulWidget {
  final String title;
  const ListingsSection({super.key, required this.title});

  @override
  _ListingsSectionState createState() => _ListingsSectionState();
}

class _ListingsSectionState extends State<ListingsSection> {
  final ListingService _listingService = ListingService();
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
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Categories(type: widget.title),
            SizedBox(
              height: 200,
              child: FutureBuilder<String>(
                future: AuthMethods().getCurrentUserId(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (userSnapshot.hasError ||
                      !userSnapshot.hasData ||
                      userSnapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('Error fetching user data.'));
                  }

                  final String currentUserId = userSnapshot.data!;

                  return StreamBuilder<List<Listing>>(
                    stream: _listingService.getListings(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('No listings available.'));
                      }

                      final listings = snapshot.data!
                          .where((listing) =>
                              listing.userId != currentUserId &&
                              listing.visibility != 'archived' &&
                              listing.visibility != 'deleted' &&
                              listing.visibility != 'hidden' &&
                              ((widget.title == 'Products' &&
                                      listing.type == 'Products for Rent') ||
                                  (widget.title == 'Services' &&
                                      listing.type != 'Products for Rent')))
                          .toList();

                      if (listings.isEmpty) {
                        return const Center(
                            child: Text('No listings available.'));
                      }

                      // Start preloading usernames
                      preloadUserNames(listings);

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: listings.length,
                        itemBuilder: (context, index) {
                          final listing = listings[index];
                          final userName = preloadedUserNames[listing.userId] ??
                              'Loading...';

                          return Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: ListingCard(
                              listing: listing,
                              userName: userName,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
