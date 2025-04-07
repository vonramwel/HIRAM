import 'package:flutter/material.dart';
import '../model/listing_model.dart';
import '../service/listing_service.dart';
import '../../auth/service/auth.dart'; // Import AuthMethods for user authentication
import '../presentation/listing_details.dart';
import '../../listing/widgets/categories.dart';

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
                            child: _listingCard(context, listing),
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

  Widget _listingCard(BuildContext context, Listing listing) {
    String imageUrl = (listing.images.isNotEmpty)
        ? listing.images.first
        : ''; // Updated placeholder image URL

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListingDetailsPage(listing: listing),
          ),
        );
      },
      child: SizedBox(
        width: 250,
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/placeholder.png', // Updated placeholder image URL,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
