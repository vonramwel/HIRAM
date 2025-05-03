import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../listing/model/listing_model.dart';

class ReportedListingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getReportedListingsStream() {
    return _firestore.collection('listing_reports').snapshots();
  }

  Future<Map<String, dynamic>> fetchListingAndOwner(String listingId) async {
    Listing? listing;
    String ownerName = 'Unknown';

    try {
      DocumentSnapshot listingSnapshot =
          await _firestore.collection('listings').doc(listingId).get();

      if (listingSnapshot.exists) {
        listing =
            Listing.fromJson(listingSnapshot.data() as Map<String, dynamic>);

        DocumentSnapshot userSnapshot =
            await _firestore.collection('User').doc(listing.userId).get();

        if (userSnapshot.exists) {
          Map<String, dynamic> userData =
              userSnapshot.data() as Map<String, dynamic>;
          ownerName = userData['name'] ?? 'Unknown';
        }
      }
    } catch (e) {
      print('Error fetching listing and owner: $e');
    }

    return {
      'listing': listing,
      'ownerName': ownerName,
      'ownerId': listing?.userId, // Add this line
    };
  }

  Future<Listing?> fetchListing(String listingId) async {
    try {
      final docSnapshot =
          await _firestore.collection('listings').doc(listingId).get();
      if (docSnapshot.exists) {
        return Listing.fromMap(docSnapshot.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error fetching listing: $e');
    }
    return null;
  }

  Future<String> fetchReporterName(String userId) async {
    try {
      DocumentSnapshot reporterDoc =
          await _firestore.collection('User').doc(userId).get();
      if (reporterDoc.exists) {
        return reporterDoc['name'] ?? 'Unknown Reporter';
      }
    } catch (e) {
      print('Error fetching reporter name: $e');
    }
    return 'Unknown Reporter';
  }
}
