// lib/reported_listing/reported_listings_tab.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'reported_listings_service.dart';
import 'reported_listings_card.dart';
import 'reported_listings_details.dart';

class ReportedListingsTab extends StatefulWidget {
  const ReportedListingsTab({Key? key}) : super(key: key);

  @override
  State<ReportedListingsTab> createState() => _ReportedListingsTabState();
}

class _ReportedListingsTabState extends State<ReportedListingsTab> {
  final ReportedListingsService _reportedListingsService =
      ReportedListingsService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _reportedListingsService.getReportedListingsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final reports = snapshot.data!.docs;

        if (reports.isEmpty) {
          return const Center(child: Text('No reported listings.'));
        }

        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index].data() as Map<String, dynamic>;

            return ReportedListingsCard(
              listingId: report['listingId'] ?? 'Unknown',
              reason: report['reason'] ?? '',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReportedListingsDetails(reportData: report),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
