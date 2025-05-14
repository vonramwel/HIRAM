import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/service/auth.dart';
import '../model/transaction_model.dart';
import 'transaction_details.dart';
import 'transaction_card.dart';

class TransactionsSection extends StatefulWidget {
  const TransactionsSection({super.key});

  @override
  _TransactionsSectionState createState() => _TransactionsSectionState();
}

class _TransactionsSectionState extends State<TransactionsSection> {
  String? _userId;
  String _selectedStatus = 'Pending for Approval';
  String _selectedView = 'Lender';
  String? _subStatus;

  final List<String> statuses = [
    'Pending for Approval',
    'In Progress',
    'Completed',
    'Cancelled',
  ];

  final Map<String, List<String>> subStatusOptions = {
    'In Progress': ['Approved', 'Lent', 'Overdue'],
    'Completed': ['Completed', 'Reviewed', 'Not yet reviewed'],
    'Cancelled': ['Disapproved', 'Expired Request'],
  };

  final List<String> views = ['Lender', 'Renter'];

  @override
  void initState() {
    super.initState();

    // Ensure _selectedView defaults to the first view
    _selectedView = views.first;

    // Ensure _selectedStatus defaults to the first status
    _selectedStatus = statuses.first;

    // If the selected status has substatus options, choose the first one
    if (subStatusOptions.containsKey(_selectedStatus)) {
      _subStatus = subStatusOptions[_selectedStatus]!.first;
    }
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
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                title: 'View Transactions As',
                child: Row(
                  children: views.map((view) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Center(child: Text(view)),
                          labelStyle: TextStyle(
                            color: _selectedView == view
                                ? Colors.white
                                : theme.colorScheme.primary,
                          ),
                          selectedColor: theme.colorScheme.primary,
                          backgroundColor: theme.colorScheme.surface,
                          selected: _selectedView == view,
                          onSelected: (_) {
                            setState(() => _selectedView = view);
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionCard(
                title: 'Filter by Status',
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: statuses.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedStatus = newValue;
                            _subStatus = subStatusOptions.containsKey(newValue)
                                ? subStatusOptions[newValue]!.first
                                : null;
                          });
                        }
                      },
                    ),
                    if (subStatusOptions.containsKey(_selectedStatus))
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Row(
                          children:
                              subStatusOptions[_selectedStatus]!.map((sub) {
                            return Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: ChoiceChip(
                                  label: Text(sub, textAlign: TextAlign.center),
                                  labelStyle: TextStyle(
                                    color: _subStatus == sub
                                        ? Colors.white
                                        : theme.colorScheme.primary,
                                  ),
                                  selectedColor: theme.colorScheme.primary,
                                  backgroundColor: theme.colorScheme.surface,
                                  selected: _subStatus == sub,
                                  onSelected: (_) {
                                    setState(() => _subStatus = sub);
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FutureBuilder<String>(
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
                        return _buildEmptyState();
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
                        bool isUserTransaction = (_selectedView == 'Lender'
                            ? t.ownerId == _userId
                            : t.renterId == _userId);

                        if (!isUserTransaction) return false;

                        if (_selectedStatus == 'Pending for Approval') {
                          return t.status == 'Pending' &&
                              t.startDate.isAfter(now);
                        } else if (_selectedStatus == 'In Progress') {
                          if (_subStatus == null) return false;
                          if (_subStatus == 'Overdue') {
                            return t.status == 'Lent' &&
                                t.endDate.isBefore(now);
                          }
                          return t.status == _subStatus;
                        } else if (_selectedStatus == 'Completed') {
                          if (_subStatus == null) return false;
                          if (_subStatus == 'Not yet reviewed') {
                            return t.status == 'Completed' &&
                                (_selectedView == 'Renter'
                                    ? t.hasReviewedByRenter != true
                                    : t.hasReviewedByLender != true);
                          }
                          if (_subStatus == 'Reviewed') {
                            return t.status == 'Completed' &&
                                (_selectedView == 'Renter'
                                    ? t.hasReviewedByRenter == true
                                    : t.hasReviewedByLender == true);
                          }
                          return t.status == 'Completed';
                        } else if (_selectedStatus == 'Cancelled') {
                          if (_subStatus == null) return false;
                          return t.status == _subStatus ||
                              (t.status == 'Cancelled' &&
                                  _subStatus == 'Disapproved');
                        }

                        return false;
                      }).toList();

                      if (filteredTransactions.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredTransactions.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surface,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: theme.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                )),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48.0),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_rounded,
                size: 90, color: theme.colorScheme.primary.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              'No transactions found.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
