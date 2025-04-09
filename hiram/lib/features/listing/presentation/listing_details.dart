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
      appBar: AppBar(title: const Text('Listing Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel or Placeholder
            widget.listing.images.isNotEmpty
                ? CarouselSlider(
                    options: CarouselOptions(
                      height: 250,
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
                    height: 250, // Match Carousel height
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        const Icon(Icons.image, size: 100, color: Colors.grey),
                  ),

            const SizedBox(height: 20),

            // Posted By
            Text(
              _isLoading ? 'Loading user...' : 'Posted by: $_postedBy',
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),

            const SizedBox(height: 10),

            // Title
            _buildTextField('Title', widget.listing.title),

            const SizedBox(height: 10),

            // Description
            _buildTextField('Description', widget.listing.description),

            const SizedBox(height: 10),

            // Type
            _buildTextField('Type', widget.listing.type),

            const SizedBox(height: 10),

            // Category
            _buildTextField('Category', widget.listing.category),

            const SizedBox(height: 10),

            // Price and Price Unit
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                      'Price', '₱${widget.listing.price.toStringAsFixed(2)}'),
                ),
                const SizedBox(width: 10),
                Expanded(
                    child: _buildTextField('Price Unit', '')), // Price Unit
              ],
            ),

            const SizedBox(height: 10),

            // Preferred Means of Transaction
            _buildTextField('Preferred Means of Transaction', ''),

            const SizedBox(height: 10),

            // Location
            _buildTextField('Location',
                '${widget.listing.barangay ?? ''}, ${widget.listing.municipality ?? ''}'),

            const SizedBox(height: 20),

            // Rent Button
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
              ),
              child: const Text("Rent"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(value),
        ),
      ],
    );
  }
}
