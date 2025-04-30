import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _service.getReportedTransactionsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final reports = snapshot.data!.docs;

        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final reportData = reports[index].data() as Map<String, dynamic>;
            return ReportedTransactionsCard(reportData: reportData);
          },
        );
      },
    );
  }
}
