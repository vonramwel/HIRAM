import 'package:flutter/material.dart';
import 'reported_transactions_details.dart';

class ReportedTransactionsCard extends StatefulWidget {
  final Map<String, dynamic> reportData;

  const ReportedTransactionsCard({Key? key, required this.reportData})
      : super(key: key);

  @override
  State<ReportedTransactionsCard> createState() =>
      _ReportedTransactionsCardState();
}

class _ReportedTransactionsCardState extends State<ReportedTransactionsCard> {
  @override
  Widget build(BuildContext context) {
    final transactionId = widget.reportData['transactionId'] ?? 'Unknown';
    final reason = widget.reportData['reason'] ?? 'No reason';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text('Transaction ID: $transactionId'),
        subtitle: Text(reason),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReportedTransactionsDetails(
                reportData: widget.reportData,
              ),
            ),
          );
        },
      ),
    );
  }
}
