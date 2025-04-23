import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/service/auth.dart';

class UserProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthMethods _authMethods = AuthMethods();

  Future<Map<String, dynamic>?> loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _firestore.collection('User').doc(user.uid).get();
    return snapshot.data();
  }

  Future<void> saveProfileChanges({
    required String phone,
    required String address,
    required String bio,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('User').doc(user.uid).update({
      'contactNumber': phone,
      'address': address,
      'bio': bio,
    });
  }

  Future<String?> pickAndUploadImage() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage == null) return null;

    final file = File(pickedImage.path);
    final fileName = 'profile_${user.uid}.jpg';
    final ref = _storage.ref().child('profile_images/$fileName');

    await ref.putFile(file);
    final imageUrl = await ref.getDownloadURL();

    await _firestore.collection('User').doc(user.uid).update({
      'imgUrl': imageUrl,
    });

    return imageUrl;
  }

  Future<List<Map<String, dynamic>>> getCurrentUserListings() async {
    try {
      final String? userId = await _authMethods.getCurrentUserId();
      if (userId == null) return [];

      final QuerySnapshot snapshot = await _firestore
          .collection('listings')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching current user listings: $e');
      return [];
    }
  }
}
