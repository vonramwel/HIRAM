// lib/report_user/service/report_user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportUserService {
  static Future<void> reportUser({
    required String userId,
    required String reason,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await FirebaseFirestore.instance.collection('user_reports').add({
      'reportedUserId': userId,
      'reportedBy': currentUser.uid,
      'reason': reason,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
