// lib/transaction/service/transaction_helpers.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/service/auth.dart';

class TransactionHelpers {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthMethods _authMethods = AuthMethods();

  Future<int> getCompletedTransactionCountForCurrentUser() async {
    final userId = await _authMethods.getCurrentUserId();
    if (userId == null) return 0;

    final QuerySnapshot ownerTransactions = await _firestore
        .collection('transactions')
        .where('ownerId', isEqualTo: userId)
        .where('status', isEqualTo: 'Completed')
        .get();

    final QuerySnapshot renterTransactions = await _firestore
        .collection('transactions')
        .where('renterId', isEqualTo: userId)
        .where('status', isEqualTo: 'Completed')
        .get();

    return ownerTransactions.docs.length + renterTransactions.docs.length;
  }

  Future<int> getActiveTransactionCountForCurrentUser() async {
    final userId = await _authMethods.getCurrentUserId();
    if (userId == null) return 0;

    final ownerActive = await _firestore
        .collection('transactions')
        .where('ownerId', isEqualTo: userId)
        .where('status', isEqualTo: 'Active')
        .get();

    final renterActive = await _firestore
        .collection('transactions')
        .where('renterId', isEqualTo: userId)
        .where('status', isEqualTo: 'Active')
        .get();

    return ownerActive.docs.length + renterActive.docs.length;
  }

  Future<int> getPendingTransactionCountForCurrentUser() async {
    final userId = await _authMethods.getCurrentUserId();
    if (userId == null) return 0;

    final ownerPending = await _firestore
        .collection('transactions')
        .where('ownerId', isEqualTo: userId)
        .where('status', isEqualTo: 'Pending')
        .get();

    final renterPending = await _firestore
        .collection('transactions')
        .where('renterId', isEqualTo: userId)
        .where('status', isEqualTo: 'Pending')
        .get();

    return ownerPending.docs.length + renterPending.docs.length;
  }

  Future<double?> getUserRating() async {
    final userId = await _authMethods.getCurrentUserId();
    if (userId == null) return null;

    final doc = await _firestore.collection('User').doc(userId).get();
    return (doc.data()?['rating'] as num?)?.toDouble();
  }

  Future<Map<String, dynamic>> getUserStats() async {
    final completed = await getCompletedTransactionCountForCurrentUser();
    final rating = await getUserRating();
    return {
      'completedTransactions': completed,
      'rating': rating,
    };
  }

  Future<double> getTotalRevenueForCurrentUser() async {
    final userId = await _authMethods.getCurrentUserId();
    if (userId == null) return 0.0;

    final QuerySnapshot transactionSnapshot = await _firestore
        .collection('transactions')
        .where('ownerId', isEqualTo: userId)
        .where('status', isEqualTo: 'Completed')
        .get();

    double totalRevenue = 0.0;

    for (var doc in transactionSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final price = (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
      totalRevenue += price;
    }

    return totalRevenue;
  }

  Future<double> getTotalExpensesForCurrentUser() async {
    final userId = await _authMethods.getCurrentUserId();
    if (userId == null) return 0.0;

    final QuerySnapshot transactionSnapshot = await _firestore
        .collection('transactions')
        .where('renterId', isEqualTo: userId)
        .where('status', isEqualTo: 'Completed')
        .get();

    double totalExpenses = 0.0;

    for (var doc in transactionSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final price = (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
      totalExpenses += price;
    }

    return totalExpenses;
  }
}
