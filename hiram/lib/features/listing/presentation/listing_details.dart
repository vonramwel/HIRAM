import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../model/listing_model.dart';
import '../../auth/service/database.dart';
import '../../transaction/presentation/rent_request_screen.dart';
import '../../review/presentation/renter_reviews_page.dart';
import '../../user_profile/presentation/otheruser_page.dart';
import 'edit_listing_page.dart';
import '../widgets/listing_action_service.dart';
import '../../report/presentation/report_listing.dart'; // <-- NEW import
import '../../../common_widgets/common_widgets.dart'; // <-- NEW import

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
  bool _isAdmin = false;
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  late Listing _currentListing;

  @override
  void initState() {
    super.initState();
    _currentListing = widget.listing;
    _fetchUserData();
    _checkIfAdmin();
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

  Future<void> _checkIfAdmin() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        Map<String, dynamic>? currentUserData =
            await _databaseMethods.getUserData(currentUser.uid);
        if (currentUserData != null && mounted) {
          setState(() {
            _isAdmin = currentUserData['userType'] == 'admin';
          });
        }
      }
    } catch (e) {}
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
                    onSelected: (value) => _handleAction(value),
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
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'viewSeller') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OtherUserProfilePage(
                                userId: _currentListing.userId),
                          ),
                        );
                      } else if (value == 'reportListing') {
                        showDialog(
                          context: context,
                          builder: (_) => ReportListingDialog(
                              listingId: _currentListing.id),
                        );
                      }
                    },
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'viewSeller',
                        child: Text('View Seller'),
                      ),
                      if (!_isAdmin)
                        const PopupMenuItem(
                          value: 'reportListing',
                          child: Text('Report Listing'),
                        ),
                    ],
                  )
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ImageCarousel(imageUrls: _currentListing.images),
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
                      CustomButton(
                        label: "View Reviews",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RenterReviewsPage(
                                  listingId: _currentListing.id),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isLoading ? 'Loading user...' : 'Posted by: $_postedBy',
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
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
                  CustomTwoFields(
                    label1: 'Type',
                    value1: _currentListing.type,
                    label2: 'Category',
                    value2: _currentListing.category,
                  ),
                  const SizedBox(height: 10),
                  CustomTwoFields(
                    label1: 'Price',
                    value1: '₱${_currentListing.price.toStringAsFixed(2)}',
                    label2: 'Price Unit',
                    value2: _currentListing.priceUnit,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Preferred Means of Transaction',
                    value:
                        _currentListing.preferredTransaction ?? 'Not specified',
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Location',
                    value:
                        '${_currentListing.barangay ?? ''}, ${_currentListing.municipality ?? ''}',
                  ),
                  const SizedBox(height: 20),
                  if (!_isOwner) ...[
                    CustomButton(
                      label: "Rent",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RentRequestScreen(listing: _currentListing),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
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
}
