import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/service/auth.dart';
import '../model/transaction_model.dart';
import 'transaction_details.dart';
import 'transaction_card.dart'; // 👈 Import the extracted card widget

class TransactionsSection extends StatefulWidget {
  final String title;
  const TransactionsSection({super.key, required this.title});

  @override
  _TransactionsSectionState createState() => _TransactionsSectionState();
}

class _TransactionsSectionState extends State<TransactionsSection> {
  String? _userId;
  String _selectedStatus = 'Pending';

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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ToggleButtons(
                isSelected: [
                  _selectedStatus == 'Pending',
                  _selectedStatus == 'In Progress',
                  _selectedStatus == 'Completed',
                  _selectedStatus == 'Cancelled',
                  _selectedStatus == 'Overdue',
                  _selectedStatus == 'Expired Request',
                  _selectedStatus == 'Not Yet Reviewed',
                ],
                onPressed: (index) {
                  setState(() {
                    _selectedStatus = [
                      'Pending',
                      'In Progress',
                      'Completed',
                      'Cancelled',
                      'Overdue',
                      'Expired Request',
                      'Not Yet Reviewed',
                    ][index];
                  });
                },
                children: const [
                  Padding(padding: EdgeInsets.all(8.0), child: Text('Pending')),
                  Padding(
                      padding: EdgeInsets.all(8.0), child: Text('In Progress')),
                  Padding(
                      padding: EdgeInsets.all(8.0), child: Text('Completed')),
                  Padding(
                      padding: EdgeInsets.all(8.0), child: Text('Cancelled')),
                  Padding(padding: EdgeInsets.all(8.0), child: Text('Overdue')),
                  Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Expired Request')),
                  Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Not Yet Reviewed')),
                ],
              ),
            ),
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

                      DateTime now = DateTime.now();

                      List<TransactionModel> transactions =
                          snapshot.data!.docs.map((doc) {
                        final map = doc.data() as Map<String, dynamic>;
                        final transaction = TransactionModel.fromMap(map);

                        if (transaction.status == 'Pending' &&
                            transaction.startDate.isBefore(now)) {
                          FirebaseFirestore.instance
                              .collection('transactions')
                              .doc(doc.id)
                              .update({'status': 'Expired Request'});
                          transaction.status = 'Expired Request';
                        }

                        return transaction;
                      }).toList();

                      final filteredTransactions = transactions.where((t) {
                        bool isUserTransaction =
                            ((widget.title == 'Transactions as Lender' &&
                                    t.ownerId == _userId) ||
                                (widget.title == 'Transactions as Renter' &&
                                    t.renterId == _userId));
                        if (!isUserTransaction) return false;

                        bool isOverdue =
                            t.status == 'Lent' && t.endDate.isBefore(now);

                        switch (_selectedStatus) {
                          case 'Pending':
                            return t.status == 'Pending' &&
                                t.startDate.isAfter(now);
                          case 'In Progress':
                            return (t.status == 'Approved' ||
                                (t.status == 'Lent' && t.endDate.isAfter(now)));
                          case 'Completed':
                            return t.status == 'Completed';
                          case 'Cancelled':
                            return t.status == 'Cancelled' ||
                                t.status == 'Disapproved';
                          case 'Overdue':
                            return isOverdue;
                          case 'Expired Request':
                            return t.status == 'Expired Request';
                          case 'Not Yet Reviewed':
                            return t.status == 'Completed' &&
                                (widget.title == 'Transactions as Renter'
                                    ? t.hasReviewedByRenter != true
                                    : t.hasReviewedByLender != true);
                          default:
                            return false;
                        }
                      }).toList();

                      if (filteredTransactions.isEmpty) {
                        return const Center(
                            child: Text('No transactions available.'));
                      }

                      return ListView.builder(
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = filteredTransactions[index];
                          return TransactionCard(
                            transaction: transaction,
                            onTap: () =>
                                _navigateToTransactionDetails(transaction),
                          );
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
