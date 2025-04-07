import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../model/listing_model.dart';
import '../../auth/service/database.dart';
import '../../transaction/presentation/rent_request_screen.dart'; // Import the rent request screen

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
      appBar: AppBar(title: Text(widget.listing.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                            'assets/images/placeholder.png', // Updated placeholder image URL,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      );
                    }).toList(),
                  )
                : Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        const Icon(Icons.image, size: 100, color: Colors.grey),
                  ),
            const SizedBox(height: 20),
            Text(
              widget.listing.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Category: ${widget.listing.category}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Text(
              'Type: ${widget.listing.type}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Text(
              'Price: ₱${widget.listing.price.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.green),
            ),
            const SizedBox(height: 20),
            Text(
              widget.listing.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              _isLoading ? 'Loading user...' : 'Posted by: $_postedBy',
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
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
              child: const Text("Rent"),
            ),
          ],
        ),
      ),
    );
  }
}
