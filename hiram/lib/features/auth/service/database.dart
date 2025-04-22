import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addUser(String userId, Map<String, dynamic> userInfoMap) {
    return _firestore.collection("User").doc(userId).set(userInfoMap);
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('User').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        return await getUserData(currentUser.uid);
      }
    } catch (e) {
      print('Error fetching current user data: $e');
    }
    return null;
  }
}
