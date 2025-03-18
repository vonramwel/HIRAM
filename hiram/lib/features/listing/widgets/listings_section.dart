import 'package:flutter/material.dart';
import '../model/listing_model.dart';
import '../service/listing_service.dart';
import '../presentation/listing_details.dart';

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: StreamBuilder<List<Listing>>(
                stream: _listingService.getListings(),
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

                  final listings = snapshot.data!
                      .where((listing) =>
                          (widget.title == 'Products' &&
                              listing.type == 'Products for Rent') ||
                          (widget.title == 'Services' &&
                              listing.type != 'Products for Rent'))
                      .toList();

                  if (listings.isEmpty) {
                    return const Center(child: Text('No listings available.'));
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: listings.length,
                    itemBuilder: (context, index) {
                      final listing = listings[index];
                      return _listingCard(context, listing);
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListingDetailsPage(listing: listing),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  'https://via.placeholder.com/150',
                  fit: BoxFit.cover,
                  width: double.infinity,
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
                        fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
