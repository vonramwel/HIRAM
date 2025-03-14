import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/listing_model.dart'; // Ensure you have a Listing model

class ListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addListing(Listing listing) async {
    final docRef = _firestore.collection('listings').doc();
    listing.id = docRef.id; // Auto-generate ID
    await docRef.set(listing.toJson());
  }

  Stream<List<Listing>> getListings() {
    return _firestore.collection('listings').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Listing.fromJson(doc.data())).toList();
    });
  }
}
