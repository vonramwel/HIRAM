import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../transaction/model/transaction_model.dart';
import '../../../listing/model/listing_model.dart';

class ReportedTransactionsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<TransactionModel?> getTransactionDetails(String transactionId) async {
    try {
      final doc =
          await _firestore.collection('transactions').doc(transactionId).get();
      if (doc.exists) {
        return TransactionModel.fromMap(doc.data()!); // Fixed
      }
    } catch (e) {
      print('Error getting transaction: $e');
    }
    return null;
  }

  Future<Listing?> getListingDetails(String listingId) async {
    try {
      final doc = await _firestore.collection('listings').doc(listingId).get();
      if (doc.exists) {
        return Listing.fromMap(doc.data()!); // Fixed
      }
    } catch (e) {
      print('Error getting listing: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> getReporterDetails(String userId) async {
    try {
      final doc = await _firestore.collection('User').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('Error getting reporter: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllReportedTransactions() async {
    try {
      final snapshot = await _firestore
          .collection('transaction_reports')
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting reported transactions: $e');
      return [];
    }
  }
}
