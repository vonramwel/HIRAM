import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/service/auth.dart';
import '../model/transaction_model.dart';

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

  Widget _buildTransactionCard(TransactionModel transaction) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
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

                      // Filter transactions based on the user role
                      final filteredTransactions = transactions
                          .where((t) =>
                              (widget.title == 'Transactions as Lender' &&
                                  t.ownerId == _userId) ||
                              (widget.title == 'Transactions as Renter' &&
                                  t.renterId == _userId))
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
