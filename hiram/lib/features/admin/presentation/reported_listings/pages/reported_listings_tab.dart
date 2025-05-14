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

  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SegmentedButton(
            segments: const [
              ButtonSegment(value: 'All', label: Text('All')),
              ButtonSegment(value: 'Hidden', label: Text('Hidden')),
              ButtonSegment(value: 'Deleted', label: Text('Deleted')),
            ],
            selected: {selectedFilter},
            onSelectionChanged: (newSelection) {
              setState(() {
                selectedFilter = newSelection.first;
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
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
                  final listingId = report['listingId'] ?? '';

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('listings')
                        .doc(listingId)
                        .get(),
                    builder: (context, listingSnapshot) {
                      if (!listingSnapshot.hasData ||
                          !listingSnapshot.data!.exists) {
                        return const SizedBox.shrink(); // Skip if not found
                      }

                      final listingData =
                          listingSnapshot.data!.data() as Map<String, dynamic>;
                      final status =
                          (listingData['visibility'] ?? 'active').toString();

                      // Apply status-based filtering
                      if (selectedFilter == 'Hidden' && status != 'hidden') {
                        return const SizedBox.shrink();
                      }
                      if (selectedFilter == 'Deleted' &&
                          status != 'deleted_admin') {
                        return const SizedBox.shrink();
                      }

                      return ReportedListingsCard(
                        listingId: listingId,
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
            },
          ),
        ),
      ],
    );
  }
}
