import 'package:flutter/material.dart';
import '../model/listing_model.dart';
import '../presentation/listing_details.dart';
import '../../auth/service/database.dart';

class ListingCard extends StatefulWidget {
  final Listing listing;

  const ListingCard({super.key, required this.listing});

  @override
  State<ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<ListingCard> {
  String _userName = 'Loading...';
  final DatabaseMethods _databaseMethods = DatabaseMethods();

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final userData =
          await _databaseMethods.getUserData(widget.listing.userId);
      if (userData != null && mounted) {
        setState(() {
          _userName = userData['name'] ?? 'Unknown User';
        });
      } else {
        setState(() {
          _userName = 'Unknown User';
        });
      }
    } catch (e) {
      setState(() {
        _userName = 'Error loading user';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl =
        widget.listing.images.isNotEmpty ? widget.listing.images.first : '';
    String location =
        '${widget.listing.barangay ?? ''}, ${widget.listing.municipality ?? ''}';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListingDetailsPage(listing: widget.listing),
          ),
        );
      },
      child: SizedBox(
        width: 250,
        height: 200,
        child: Card(
          color: const Color.fromARGB(215, 198, 196, 196),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  color: Colors.grey[200],
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
                          : const Center(child: Icon(Icons.image, size: 40)),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 14, color: Colors.black54),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 150,
                              child: Text(
                                location,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black87),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.bookmark_border,
                              size: 18, color: Colors.black87),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'PHP ${widget.listing.price.toStringAsFixed(0)} ${widget.listing.priceUnit}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                child: Text(
                  widget.listing.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                child: Text(
                  widget.listing.description,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Text(
                    'Posted by: $_userName',
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
