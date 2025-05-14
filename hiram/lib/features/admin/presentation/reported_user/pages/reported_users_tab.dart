import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'report_user_card.dart';
import 'reported_user_service.dart';
import 'reported_user_detail_page.dart';

class ReportedUsersTab extends StatefulWidget {
  const ReportedUsersTab({Key? key}) : super(key: key);

  @override
  _ReportedUsersTabState createState() => _ReportedUsersTabState();
}

class _ReportedUsersTabState extends State<ReportedUsersTab> {
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
              ButtonSegment(value: 'Frozen', label: Text('Frozen')),
              ButtonSegment(value: 'Banned', label: Text('Banned')),
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
            stream: AdminUserService.getReportedUsersStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final reports = snapshot.data!.docs;

              return ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index].data() as Map<String, dynamic>;
                  final reportedUserId = report['reportedUserId'] ?? '';
                  final reportedById = report['reportedBy'] ?? '';
                  final reportTimestamp = report['timestamp'] as Timestamp?;

                  return FutureBuilder<Map<String, dynamic>?>(
                    future: AdminUserService.getUserDataById(reportedUserId),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) {
                        return const ListTile(
                          title: Text('Loading user...'),
                          subtitle: Text('Fetching user details'),
                        );
                      }

                      final userData = userSnapshot.data!;
                      final userName = userData['name'] ?? 'Unknown User';
                      final userImageUrl = userData['imgUrl'] ?? '';
                      final userStatus = (userData['accountStatus'] ?? 'active')
                          .toString()
                          .toLowerCase();

                      // Apply filter
                      if (selectedFilter == 'Frozen' && userStatus != 'locked')
                        return const SizedBox.shrink();
                      if (selectedFilter == 'Banned' && userStatus != 'banned')
                        return const SizedBox.shrink();

                      return ReportCard(
                        title: userName,
                        subtitle: report['reason'] ?? '',
                        imageUrl: userImageUrl,
                        reportedUserId: reportedUserId,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReportedUserDetailPage(
                                userName: userName,
                                userImageUrl: userImageUrl,
                                reportReason: report['reason'] ?? '',
                                userData: userData,
                                reportedById: reportedById,
                                reportTimestamp: reportTimestamp,
                              ),
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
