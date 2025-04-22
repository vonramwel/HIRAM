import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Adds a new user document to Firestore under the "User" collection.
  Future<void> addUser(String userId, Map<String, dynamic> userInfoMap) {
    return _firestore.collection("User").doc(userId).set(userInfoMap);
  }

  Future<bool> checkUserExists(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('User').doc(uid).get();
    return doc.exists;
  }

  /// Retrieves data of a specific user by their user ID.
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

  /// Retrieves the currently signed-in user's data.
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

  /// Updates the currently signed-in user's data.
  Future<void> updateCurrentUserData(Map<String, dynamic> newData) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _firestore
            .collection("User")
            .doc(currentUser.uid)
            .update(newData);
      }
    } catch (e) {
      print('Error updating user data: $e');
    }
  }
}
