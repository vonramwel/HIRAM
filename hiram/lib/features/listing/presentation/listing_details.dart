import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../model/listing_model.dart';
import '../../auth/service/database.dart';
import '../../transaction/presentation/rent_request_screen.dart';

class ListingDetailsPage extends StatefulWidget {
  final Listing listing;
  const ListingDetailsPage({super.key, required this.listing});

  @override
  _ListingDetailsPageState createState() => _ListingDetailsPageState();
}

class _ListingDetailsPageState extends State<ListingDetailsPage> {
  String _postedBy = 'Loading...';
  bool _isLoading = true;
  final DatabaseMethods _databaseMethods = DatabaseMethods();

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      Map<String, dynamic>? userData =
          await _databaseMethods.getUserData(widget.listing.userId);
      if (userData != null && mounted) {
        setState(() {
          _postedBy = userData['name'] ?? 'Unknown User';
          _isLoading = false;
        });
      } else {
        setState(() {
          _postedBy = 'Unknown User';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _postedBy = 'Error loading user';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
              ),
              child: const Text("Contact Seller"),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image Carousel or Placeholder
            widget.listing.images.isNotEmpty
                ? CarouselSlider(
                    options: CarouselOptions(
                      height: 180,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: true,
                      autoPlay: true,
                    ),
                    items: widget.listing.images.map((imageUrl) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                            'assets/images/placeholder.png',
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      );
                    }).toList(),
                  )
                : Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        const Icon(Icons.image, size: 80, color: Colors.grey),
                  ),

            const SizedBox(height: 10),

            // Rating and View Reviews
            Column(
              children: const [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star_border),
                    Icon(Icons.star_border),
                    Icon(Icons.star_border),
                    Icon(Icons.star_border),
                    Icon(Icons.star_border),
                  ],
                ),
                Text("Rating: 4.95"),
                SizedBox(height: 5),
                ElevatedButton(
                  onPressed: null,
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll<Color>(Colors.black87),
                    foregroundColor:
                        MaterialStatePropertyAll<Color>(Colors.white),
                  ),
                  child: Text("View Reviews"),
                )
              ],
            ),

            const SizedBox(height: 10),

            // Posted By
            Text(
              _isLoading ? 'Loading user...' : 'Posted by: $_postedBy',
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),

            const SizedBox(height: 10),

            // Title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.listing.title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 5),

            // Description
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.listing.description,
                style: const TextStyle(fontSize: 14),
              ),
            ),

            const SizedBox(height: 20),

            // Form Fields Layout
            _buildTwoFields('Type', widget.listing.type, 'Category',
                widget.listing.category),

            const SizedBox(height: 10),

            _buildTwoFields(
                'Price',
                '₱${widget.listing.price.toStringAsFixed(2)}',
                'Price Unit',
                widget.listing.priceUnit),

            const SizedBox(height: 10),

            _buildTextField('Preferred Means of Transaction',
                widget.listing.preferredTransaction ?? 'Not specified'),

            const SizedBox(height: 10),

            _buildTextField('Location',
                '${widget.listing.barangay ?? ''}, ${widget.listing.municipality ?? ''}'),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RentRequestScreen(listing: widget.listing),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
              ),
              child: const Text("Rent"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String value) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildTwoFields(
      String label1, String value1, String label2, String value2) {
    return Row(
      children: [
        Expanded(child: _buildTextField(label1, value1)),
        const SizedBox(width: 10),
        Expanded(child: _buildTextField(label2, value2)),
      ],
    );
  }
}
