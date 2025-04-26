import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/listing_model.dart';
import '../service/listing_service.dart';
import '../../auth/service/auth.dart';
import '../widgets/listing_card.dart';
import '../presentation/listing_details.dart';

class CategoryListingsPage extends StatefulWidget {
  final String category;
  final String type; // Products or Services

  CategoryListingsPage({required this.category, required this.type});

  @override
  _CategoryListingsPageState createState() => _CategoryListingsPageState();
}

class _CategoryListingsPageState extends State<CategoryListingsPage> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: FutureBuilder<String>(
        future: AuthMethods().getCurrentUserId(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (userSnapshot.hasError ||
              !userSnapshot.hasData ||
              userSnapshot.data!.isEmpty) {
            return const Center(child: Text('Error fetching user data.'));
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

              final listings = snapshot.data!
                  .where((listing) =>
                      listing.userId != currentUserId &&
                      listing.category == widget.category &&
                      ((widget.type == 'Products' &&
                              listing.type == 'Products for Rent') ||
                          (widget.type == 'Services' &&
                              listing.type != 'Products for Rent')))
                  .toList();

              if (listings.isEmpty) {
                return const Center(child: Text('No listings found.'));
              }

              // Start preloading usernames
              preloadUserNames(listings);

              return ListView.builder(
                itemCount: listings.length,
                itemBuilder: (context, index) {
                  final listing = listings[index];
                  final userName =
                      preloadedUserNames[listing.userId] ?? 'Loading...';

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ListingDetailsPage(listing: listing),
                          ),
                        );
                      },
                      child: ListingCard(
                        listing: listing,
                        userName: userName,
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
