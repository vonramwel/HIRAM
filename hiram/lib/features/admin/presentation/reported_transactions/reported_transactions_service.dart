import 'package:cloud_firestore/cloud_firestore.dart';

class ReportedTransactionsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getReportedTransactionsStream() {
    return _firestore.collection('transaction_reports').snapshots();
  }

  Future<Map<String, dynamic>?> getReporterDetails(String userId) async {
    try {
      final doc = await _firestore.collection('User').doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching reporter details: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> getTransactionDetails(
      String transactionId) async {
    try {
      final doc =
          await _firestore.collection('transactions').doc(transactionId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching transaction details: $e');
    }
    return null;
  }
}
