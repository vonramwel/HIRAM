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
}
