import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../listing/model/listing_model.dart';
import '../../listing/widgets/listing_card.dart';

class ArchivedListingsPage extends StatelessWidget {
  const ArchivedListingsPage({super.key});

  Stream<List<Listing>> getArchivedListingsStream() {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final String? currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null) {
      // Return an empty stream if no user is logged in
      return Stream.value([]);
    }

    return _firestore
        .collection('listings')
        .where('visibility', isEqualTo: 'archived')
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Listing.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archived Listings'),
      ),
      body: StreamBuilder<List<Listing>>(
        stream: getArchivedListingsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No archived listings available.'));
          }

          final listings = snapshot.data!;

          return ListView.builder(
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListingCard(
                  listing: listing,
                  userName: 'You', // Can skip since it's your own listings
                ),
              );
            },
          );
        },
      ),
    );
  }
}
