import 'package:flutter/material.dart';
import 'reported_transactions_service.dart';

class ReportedTransactionsDetails extends StatefulWidget {
  final Map<String, dynamic> reportData;

  const ReportedTransactionsDetails({Key? key, required this.reportData})
      : super(key: key);

  @override
  State<ReportedTransactionsDetails> createState() =>
      _ReportedTransactionsDetailsState();
}

class _ReportedTransactionsDetailsState
    extends State<ReportedTransactionsDetails> {
  final ReportedTransactionsService _service = ReportedTransactionsService();

  Map<String, dynamic>? _transactionDetails;
  String _reporterName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final transactionId = widget.reportData['transactionId'];
    final reporterId = widget.reportData['reportedBy'];

    final transaction = await _service.getTransactionDetails(transactionId);
    final reporter = await _service.getReporterDetails(reporterId);

    if (mounted) {
      setState(() {
        _transactionDetails = transaction;
        _reporterName = reporter?['name'] ?? 'Unknown Reporter';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reason = widget.reportData['reason'] ?? 'No reason provided';
    final timestamp = widget.reportData['timestamp'];
    final reportedAt =
        timestamp != null ? (timestamp.toDate() as DateTime) : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Reported Transaction Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _transactionDetails == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaction ID: ${widget.reportData['transactionId']}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text('Reason: $reason'),
                  const SizedBox(height: 10),
                  Text('Reported By: $_reporterName'),
                  const SizedBox(height: 10),
                  if (reportedAt != null)
                    Text(
                        'Reported At: ${reportedAt.day}/${reportedAt.month}/${reportedAt.year} ${reportedAt.hour}:${reportedAt.minute}'),
                  const SizedBox(height: 20),
                  const Text('Transaction Info:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                      'Status: ${_transactionDetails!['status'] ?? 'Unknown'}'),
                  Text(
                      'Total Price: ${_transactionDetails!['totalPrice']?.toString() ?? 'Unknown'}'),
                  // Add more fields as needed
                ],
              ),
      ),
    );
  }
}
