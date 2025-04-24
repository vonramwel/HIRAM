import 'package:flutter/material.dart';
import '../model/listing_model.dart';
import '../service/listing_service.dart';
import '../../auth/service/auth.dart';
import 'listing_details.dart';
import '../widgets/listing_card.dart'; // Importing the shared ListingCard widget

class CategoryListingsPage extends StatelessWidget {
  final String category;
  final String type; // Products or Services

  CategoryListingsPage({required this.category, required this.type});

  final ListingService _listingService = ListingService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
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
                      listing.category == category &&
                      ((type == 'Products' &&
                              listing.type == 'Products for Rent') ||
                          (type == 'Services' &&
                              listing.type != 'Products for Rent')))
                  .toList();

              if (listings.isEmpty) {
                return const Center(child: Text('No listings found.'));
              }

              return ListView.builder(
                itemCount: listings.length,
                itemBuilder: (context, index) {
                  final listing = listings[index];
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
                      child: ListingCard(listing: listing),
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
