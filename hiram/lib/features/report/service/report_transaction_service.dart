// lib/transaction/service/report_transaction_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportTransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> reportTransaction({
    required String transactionId,
    required String reason,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    try {
      await _firestore.collection('transaction_reports').add({
        'transactionId': transactionId,
        'reportedBy': currentUser.uid,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to report transaction: $e');
    }
  }
}
