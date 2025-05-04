import 'package:flutter/material.dart';
import 'reported_transactions_details.dart';
import 'reported_transactions_service.dart';
import '../../../transaction/model/transaction_model.dart';
import '../../../listing/model/listing_model.dart';

class ReportedTransactionsCard extends StatefulWidget {
  final Map<String, dynamic> reportData;

  const ReportedTransactionsCard({Key? key, required this.reportData})
      : super(key: key);

  @override
  State<ReportedTransactionsCard> createState() =>
      _ReportedTransactionsCardState();
}

class _ReportedTransactionsCardState extends State<ReportedTransactionsCard> {
  final ReportedTransactionsService _service = ReportedTransactionsService();

  TransactionModel? _transaction;
  Listing? _listing;
  String reporterName = 'Loading...';
  DateTime? reportedAt;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final transactionId = widget.reportData['transactionId'];
    final reporterId = widget.reportData['reportedBy'];
    final timestamp = widget.reportData['timestamp'];

    final transaction = await _service.getTransactionDetails(transactionId);
    final reporter = await _service.getReporterDetails(reporterId);

    Listing? listing;
    if (transaction != null) {
      listing = await _service.getListingDetails(transaction.listingId);
    }

    if (mounted) {
      setState(() {
        _transaction = transaction;
        _listing = listing;
        reporterName = reporter?['name'] ?? 'Unknown Reporter';
        reportedAt = timestamp?.toDate();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reason = widget.reportData['reason'] ?? 'No reason';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(_listing?.title ?? 'Loading...',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reported by: $reporterName'),
            Text('Reason: $reason'),
            if (reportedAt != null)
              Text(
                'Date: ${reportedAt!.day}/${reportedAt!.month}/${reportedAt!.year}',
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
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
