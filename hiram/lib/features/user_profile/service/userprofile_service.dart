// lib/user/service/userprofile_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/service/auth.dart';

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthMethods _authMethods = AuthMethods();

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
