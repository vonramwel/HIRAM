import 'package:flutter/material.dart';
import 'reported_transactions_card.dart';
import 'reported_transactions_service.dart';

class ReportedTransactionsTab extends StatefulWidget {
  const ReportedTransactionsTab({Key? key}) : super(key: key);

  @override
  State<ReportedTransactionsTab> createState() =>
      _ReportedTransactionsTabState();
}

class _ReportedTransactionsTabState extends State<ReportedTransactionsTab> {
  final ReportedTransactionsService _service = ReportedTransactionsService();
  late Future<List<Map<String, dynamic>>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _reportsFuture = _service.getAllReportedTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _reportsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Failed to load reports.'));
        }

        final reports = snapshot.data!;
        if (reports.isEmpty) {
          return const Center(child: Text('No reported transactions.'));
        }

        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            return ReportedTransactionsCard(reportData: reports[index]);
          },
        );
      },
    );
  }
}
