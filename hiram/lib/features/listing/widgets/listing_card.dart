import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/listing_model.dart';
import '../presentation/listing_details.dart';

class ListingCard extends StatefulWidget {
  final Listing listing;
  final String userName;

  const ListingCard({super.key, required this.listing, required this.userName});

  @override
  State<ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<ListingCard> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('listings')
          .doc(widget.listing.id)
          .snapshots(),
      builder: (context, listingSnapshot) {
        if (!listingSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        Listing updatedListing = Listing.fromJson(
          listingSnapshot.data!.data() as Map<String, dynamic>,
        );

        String imageUrl =
            updatedListing.images.isNotEmpty ? updatedListing.images.first : '';

        String barangay = updatedListing.barangay?.trim() ?? '';
        String municipality = updatedListing.municipality?.trim() ?? '';
        String location = (barangay.isEmpty && municipality.isEmpty)
            ? 'No location'
            : '$barangay, $municipality';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ListingDetailsPage(listing: updatedListing),
              ),
            );
          },
          child: SizedBox(
            width: 250,
            height: 200,
            child: Card(
              color: const Color(0xFFD4D4D4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      color: const Color(0xFFB3B3B3),
                      height: 140,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  height: 140,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                          child: Icon(Icons.image, size: 40)),
                                )
                              : const Center(
                                  child: Icon(Icons.image, size: 40)),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 14, color: Color(0xFF2B2B2B)),
                                const SizedBox(width: 4),
                                SizedBox(
                                  width: 150,
                                  child: Text(
                                    location,
                                    style: const TextStyle(
                                        fontSize: 12, color: Color(0xFF2B2B2B)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2B2B2B),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'PHP ${updatedListing.price.toStringAsFixed(0)} ${updatedListing.priceUnit}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star,
                                      size: 14, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    (updatedListing.rating != null &&
                                            updatedListing.ratingCount !=
                                                null &&
                                            updatedListing.ratingCount! > 0)
                                        ? '${updatedListing.rating!.toStringAsFixed(1)} (${updatedListing.ratingCount})'
                                        : 'No rating',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Removed side padding here
                  Text(
                    ' ${updatedListing.title}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF2B2B2B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '  ${updatedListing.description}',
                    style:
                        const TextStyle(fontSize: 12, color: Color(0xFF4D4D4D)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Posted by: ${widget.userName}   ',
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF4D4D4D)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
