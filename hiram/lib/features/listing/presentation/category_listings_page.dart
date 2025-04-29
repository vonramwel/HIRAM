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

  const CategoryListingsPage({
    required this.category,
    required this.type,
    Key? key,
  }) : super(key: key);

  @override
  _CategoryListingsPageState createState() => _CategoryListingsPageState();
}

class _CategoryListingsPageState extends State<CategoryListingsPage> {
  final ListingService _listingService = ListingService();
  final Map<String, String> preloadedUserNames = {};

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
      backgroundColor: const Color(0xFFF5F5F5), // Salt White
      appBar: AppBar(
        title: Text(
          widget.category,
          style: const TextStyle(
            color: Color(0xFFF5F5F5), // Salt White
            // fontWeight: FontWeight,
          ),
        ),
        backgroundColor: const Color(0xFF2E2E2E), // Pepper Black
        iconTheme: const IconThemeData(color: Color(0xFFF5F5F5)),
      ),
      body: FutureBuilder<String>(
        future: AuthMethods().getCurrentUserId(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E2E2E)),
            );
          }
          if (userSnapshot.hasError ||
              !userSnapshot.hasData ||
              userSnapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Error fetching user data.',
                style: TextStyle(color: Color(0xFF2E2E2E)), // Pepper Black
              ),
            );
          }

          final String currentUserId = userSnapshot.data!;

          return StreamBuilder<List<Listing>>(
            stream: _listingService.getListings(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2E2E2E)),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Color(0xFF2E2E2E)),
                  ),
                );
              }

              final listings = snapshot.data!
                  .where((listing) =>
                      listing.userId != currentUserId &&
                      listing.visibility != 'archived' &&
                      listing.visibility != 'deleted' &&
                      listing.category == widget.category &&
                      ((widget.type == 'Products' &&
                              listing.type == 'Products for Rent') ||
                          (widget.type == 'Services' &&
                              listing.type != 'Products for Rent')))
                  .toList();

              if (listings.isEmpty) {
                return const Center(
                  child: Text(
                    'No listings found.',
                    style: TextStyle(color: Color(0xFF888888)), // Accent Gray
                  ),
                );
              }

              preloadUserNames(listings);

              return ListView.builder(
                itemCount: listings.length,
                itemBuilder: (context, index) {
                  final listing = listings[index];
                  final userName =
                      preloadedUserNames[listing.userId] ?? 'Loading...';

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 6.0),
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
