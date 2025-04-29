import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUserService {
  static Stream<QuerySnapshot> getReportedUsersStream() {
    return FirebaseFirestore.instance.collection('user_reports').snapshots();
  }

  static Future<Map<String, dynamic>?> getUserDataById(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('User').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
    return null;
  }
}
