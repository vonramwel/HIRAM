import 'package:flutter/material.dart';

class ReportedUserDetailPage extends StatelessWidget {
  final String userName;
  final String userImageUrl;
  final String reportReason;
  final Map<String, dynamic> userData;

  const ReportedUserDetailPage({
    Key? key,
    required this.userName,
    required this.userImageUrl,
    required this.reportReason,
    required this.userData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reported User Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  userImageUrl.isNotEmpty ? NetworkImage(userImageUrl) : null,
              child: userImageUrl.isEmpty
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              userName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Report Reason: $reportReason',
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(height: 40),
            // Display additional user information
            Expanded(
              child: ListView(
                children: userData.entries.map((entry) {
                  return ListTile(
                    title: Text('${entry.key}'),
                    subtitle: Text('${entry.value}'),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
