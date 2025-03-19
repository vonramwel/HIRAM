import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/service/auth.dart';
import '../model/transaction_model.dart';
import 'transaction_details.dart';

class TransactionsSection extends StatefulWidget {
  final String title;
  const TransactionsSection({super.key, required this.title});

  @override
  _TransactionsSectionState createState() => _TransactionsSectionState();
}

class _TransactionsSectionState extends State<TransactionsSection> {
  String? _userId;

  @override
  void initState() {
    super.initState();
  }

  void _navigateToTransactionDetails(TransactionModel transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetails(transaction: transaction),
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('listings')
          .doc(transaction.listingId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: const Text("Listing not found"),
              subtitle: Text("Transaction ID: ${transaction.listingId}"),
            ),
          );
        }

        final listingData = snapshot.data!.data() as Map<String, dynamic>;
        final List<dynamic>? images = listingData['images'] as List<dynamic>?;

        final String imageUrl = (images != null && images.isNotEmpty)
            ? images[0] as String
            : 'https://via.placeholder.com/150';

        return GestureDetector(
          onTap: () => _navigateToTransactionDetails(transaction),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text("Payment: ${transaction.paymentMethod}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Start: ${transaction.startDate.toLocal()}"),
                  Text("End: ${transaction.endDate.toLocal()}"),
                  Text("Notes: ${transaction.notes}"),
                  Text("Status: ${transaction.status}"),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: FutureBuilder<String>(
                future: AuthMethods().getCurrentUserId(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (userSnapshot.hasError ||
                      !userSnapshot.hasData ||
                      userSnapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('Error fetching user data.'));
                  }

                  _userId = userSnapshot.data!;

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('transactions')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text('No transactions available.'));
                      }

                      List<TransactionModel> transactions = snapshot.data!.docs
                          .map((doc) => TransactionModel.fromMap(
                              doc.data() as Map<String, dynamic>))
                          .toList();

                      final filteredTransactions = transactions
                          .where((t) =>
                              ((widget.title == 'Transactions as Lender' &&
                                      t.ownerId == _userId &&
                                      t.status != 'Cancelled') ||
                                  (widget.title == 'Transactions as Renter' &&
                                      t.renterId == _userId)))
                          .toList();

                      if (filteredTransactions.isEmpty) {
                        return const Center(
                            child: Text('No transactions available.'));
                      }

                      return ListView.builder(
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          return _buildTransactionCard(
                              filteredTransactions[index]);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
