import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/service/auth.dart';
import '../model/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addTransaction(TransactionModel transaction) async {
    DocumentReference docRef =
        await _firestore.collection('transactions').add(transaction.toMap());

    // Update the transaction with the generated ID
    await docRef.update({'transactionId': docRef.id});
  }

  Future<String?> getCurrentUserId() async {
    return await AuthMethods().getCurrentUserId();
  }

  Future<String?> getTransactionId(String listingId, String renterId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('transactions')
        .where('listingId', isEqualTo: listingId)
        .where('renterId', isEqualTo: renterId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot
          .docs.first.id; // Return the document ID (transactionId)
    }
    return null; // Return null if no transaction is found
  }

  Future<String> generateTransactionCode(String transactionId) async {
    final random = Random();
    String generatedCode = (1000 + random.nextInt(9000)).toString();

    await _firestore.collection('transactions').doc(transactionId).update({
      'transactionCode': generatedCode,
    });

    return generatedCode;
  }

  Future<bool> validateTransactionCode(
      String transactionId, String inputCode, String action) async {
    DocumentSnapshot transactionSnapshot =
        await _firestore.collection('transactions').doc(transactionId).get();

    if (transactionSnapshot.exists) {
      String? storedCode = transactionSnapshot['transactionCode'];
      if (storedCode == inputCode && action == 'Approved') {
        await _firestore.collection('transactions').doc(transactionId).update({
          'status': 'Lent',
          'transactionCode': '', // Reset transaction code
        });
        return true;
      }
      if (storedCode == inputCode && action == 'Lent') {
        await _firestore.collection('transactions').doc(transactionId).update({
          'status': 'Completed',
          'transactionCode': '', // Reset transaction code
        });
        return true;
      }
    }
    return false;
  }

  Future<void> updateTransactionStatus(String transactionId, String listingId,
      String renterId, String newStatus) async {
    await _firestore
        .collection('transactions')
        .where('transactionId', isEqualTo: transactionId)
        .where('listingId', isEqualTo: listingId)
        .where('renterId', isEqualTo: renterId)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.update({'status': newStatus});
      }
    });
  }

  Future<void> updateTransactionStatusAndTotalPrice(
    String transactionId,
    String listingId,
    String renterId,
    String newStatus,
    double offeredPrice,
  ) async {
    await _firestore
        .collection('transactions')
        .where('transactionId', isEqualTo: transactionId)
        .where('listingId', isEqualTo: listingId)
        .where('renterId', isEqualTo: renterId)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.update({
          'status': newStatus,
          'totalPrice': offeredPrice,
        });
      }
    });
  }

  Future<void> updateTransactionStatusOnly(
    String transactionId,
    String listingId,
    String renterId,
    String newStatus,
  ) async {
    await _firestore
        .collection('transactions')
        .where('transactionId', isEqualTo: transactionId)
        .where('listingId', isEqualTo: listingId)
        .where('renterId', isEqualTo: renterId)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.update({'status': newStatus});
      }
    });
  }
}
