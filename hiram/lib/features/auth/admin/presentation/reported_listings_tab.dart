import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'reported_user/report_card.dart';

class ReportedListingsTab extends StatelessWidget {
  const ReportedListingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('listing_reports').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final reports = snapshot.data!.docs;

        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index].data() as Map<String, dynamic>;
            // return ReportCard(
            //   title: "Listing ID: ${report['listingId']}",
            //   subtitle: report['reason'] ?? '',
            //   onAlert: () {},
            // );
          },
        );
      },
    );
  }
}
