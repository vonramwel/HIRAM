// lib/user/pages/mylistings_page.dart
import 'package:flutter/material.dart';
import '../../listing/model/listing_model.dart';
import '../../listing/widgets/listing_card.dart';
import '../service/userprofile_service.dart';

class MyListingsPage extends StatefulWidget {
  const MyListingsPage({super.key});

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
  final UserProfileService _userProfileService = UserProfileService();
  List<Listing> _myListings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyListings();
  }

  Future<void> _fetchMyListings() async {
    final listingsData = await _userProfileService.getCurrentUserListings();
    setState(() {
      _myListings =
          listingsData.map<Listing>((data) => Listing.fromMap(data)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Listings"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myListings.isEmpty
              ? const Center(child: Text("You have no listings yet."))
              : ListView.builder(
                  itemCount: _myListings.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListingCard(listing: _myListings[index]),
                    );
                  },
                ),
    );
  }
}
