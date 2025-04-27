// listing_details.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/listing_model.dart';
import '../../auth/service/database.dart';
import '../../transaction/presentation/rent_request_screen.dart';
import '../../review/presentation/renter_reviews_page.dart';
import '../../user_profile/presentation/otheruser_page.dart';
import 'edit_listing_page.dart';
import '../widgets/listing_action_service.dart'; // <-- Already added

class ListingDetailsPage extends StatefulWidget {
  final Listing listing;
  const ListingDetailsPage({super.key, required this.listing});

  @override
  _ListingDetailsPageState createState() => _ListingDetailsPageState();
}

class _ListingDetailsPageState extends State<ListingDetailsPage> {
  String _postedBy = 'Loading...';
  bool _isLoading = true;
  bool _isOwner = false;
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  late Listing _currentListing;

  @override
  void initState() {
    super.initState();
    _currentListing = widget.listing;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        setState(() {
          _isOwner = currentUser.uid == widget.listing.userId;
        });
      }

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

  void _updateLocalVisibility(String status) {
    setState(() {
      _currentListing.visibility = status;
    });
  }

  void _handleAction(String action) {
    ListingActionService.handleAction(
      context: context,
      listingId: _currentListing.id,
      action: action,
      onVisibilityUpdated: _updateLocalVisibility,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('listings')
          .doc(widget.listing.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          _currentListing = Listing.fromMap(data);

          return Scaffold(
            appBar: AppBar(
              actions: [
                if (_isOwner) ...[
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditListingPage(listing: _currentListing),
                        ),
                      );
                    },
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      _handleAction(value);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: _currentListing.visibility == 'archived'
                            ? 'unarchive'
                            : 'archive',
                        child: Text(
                          _currentListing.visibility == 'archived'
                              ? 'Unarchive Listing'
                              : 'Archive Listing',
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete Listing'),
                      ),
                    ],
                  ),
                ] else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OtherUserProfilePage(
                              userId: _currentListing.userId,
                            ),
                          ),
                        );
                      },
                      child: const Text("View Seller"),
                    ),
                  )
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _currentListing.images.isNotEmpty
                      ? CarouselSlider(
                          options: CarouselOptions(
                            height: 180,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: true,
                            autoPlay: true,
                          ),
                          items: _currentListing.images.map((imageUrl) {
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
                          child: const Icon(Icons.image,
                              size: 80, color: Colors.grey),
                        ),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.star_border),
                          Icon(Icons.star_border),
                          Icon(Icons.star_border),
                          Icon(Icons.star_border),
                          Icon(Icons.star_border),
                        ],
                      ),
                      const Text("Rating: 4.95"),
                      const SizedBox(height: 5),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RenterReviewsPage(
                                  listingId: _currentListing.id),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("View Reviews"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isLoading ? 'Loading user...' : 'Posted by: $_postedBy',
                    style: const TextStyle(
                        fontSize: 14, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _currentListing.title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _currentListing.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTwoFields('Type', _currentListing.type, 'Category',
                      _currentListing.category),
                  const SizedBox(height: 10),
                  _buildTwoFields(
                    'Price',
                    '₱${_currentListing.price.toStringAsFixed(2)}',
                    'Price Unit',
                    _currentListing.priceUnit,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    'Preferred Means of Transaction',
                    _currentListing.preferredTransaction ?? 'Not specified',
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    'Location',
                    '${_currentListing.barangay ?? ''}, ${_currentListing.municipality ?? ''}',
                  ),
                  const SizedBox(height: 20),
                  if (!_isOwner)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RentRequestScreen(listing: _currentListing),
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
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return const Scaffold(
            body: Center(child: Text('Listing not found')),
          );
        }
      },
    );
  }

  Widget _buildTextField(String label, String value) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
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
