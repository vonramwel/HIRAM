import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../model/listing_model.dart';
import 'dart:io';

class ListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> addListing(Listing listing) async {
    final docRef = _firestore.collection('listings').doc();
    listing.id = docRef.id; // Auto-generate ID
    await docRef.set(listing.toJson());
  }

  Future<String> uploadImage(File image, String listingId) async {
    try {
      final ref = _storage.ref().child(
          'listings/$listingId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception("Image upload failed: $e");
    }
  }

  Stream<List<Listing>> getListings() {
    return _firestore.collection('listings').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Listing.fromJson(doc.data())).toList();
    });
  }

  Future<void> updateListing(Listing listing) async {
    try {
      await _firestore
          .collection('listings')
          .doc(listing.id)
          .update(listing.toJson());
    } catch (e) {
      throw Exception('Failed to update listing: $e');
    }
  }
}
