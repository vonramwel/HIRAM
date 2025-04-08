import 'package:flutter/material.dart';
import '../model/listing_model.dart';
import '../service/listing_service.dart';
import '../../auth/service/auth.dart'; // Import AuthMethods for user authentication
import '../presentation/listing_details.dart';
import '../../listing/widgets/categories.dart';
import '../widgets/listing_card.dart'; // New import

class ListingsSection extends StatefulWidget {
  final String title;
  const ListingsSection({super.key, required this.title});

  @override
  _ListingsSectionState createState() => _ListingsSectionState();
}

class _ListingsSectionState extends State<ListingsSection> {
  final ListingService _listingService = ListingService();

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

                      // Filter listings: Exclude those posted by the current user
                      final listings = snapshot.data!
                          .where((listing) =>
                              listing.userId != currentUserId &&
                              ((widget.title == 'Products' &&
                                      listing.type == 'Products for Rent') ||
                                  (widget.title == 'Services' &&
                                      listing.type != 'Products for Rent')))
                          .toList();

                      if (listings.isEmpty) {
                        return const Center(
                            child: Text('No listings available.'));
                      }

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: listings.length,
                        itemBuilder: (context, index) {
                          final listing = listings[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: ListingCard(
                                listing: listing), // Use the extracted widget
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
