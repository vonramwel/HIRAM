import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../user_profile/presentation/otheruser_page.dart';

class ReportedUserDetailPage extends StatefulWidget {
  final String userName;
  final String userImageUrl;
  final String reportReason;
  final Map<String, dynamic> userData;
  final String reportedById; // <-- add this
  final Timestamp? reportTimestamp; // <-- add this

  const ReportedUserDetailPage({
    Key? key,
    required this.userName,
    required this.userImageUrl,
    required this.reportReason,
    required this.userData,
    required this.reportedById,
    required this.reportTimestamp,
  }) : super(key: key);

  @override
  State<ReportedUserDetailPage> createState() => _ReportedUserDetailPageState();
}

class _ReportedUserDetailPageState extends State<ReportedUserDetailPage> {
  String? reporterName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReporterName();
  }

  Future<void> fetchReporterName() async {
    try {
      DocumentSnapshot reporterDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(widget.reportedById)
          .get();
      if (reporterDoc.exists) {
        setState(() {
          reporterName = reporterDoc['name'] ?? 'Unknown Reporter';
          isLoading = false;
        });
      } else {
        setState(() {
          reporterName = 'Unknown Reporter';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching reporter: $e');
      setState(() {
        reporterName = 'Unknown Reporter';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prepare grouped fields
    String contactInfo = '';
    if (widget.userData['phoneNumber'] != null) {
      contactInfo += 'Phone: ${widget.userData['phoneNumber']}';
    }
    if (widget.userData['email'] != null) {
      if (contactInfo.isNotEmpty) contactInfo += '\n';
      contactInfo += 'Email: ${widget.userData['email']}';
    }
    if (widget.userData['address'] != null) {
      if (contactInfo.isNotEmpty) contactInfo += '\n';
      contactInfo += 'Address: ${widget.userData['address']}';
    }

    String formattedDate = widget.reportTimestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(
                widget.reportTimestamp!.millisecondsSinceEpoch)
            .toLocal()
            .toString()
        : 'Unknown Date';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reported User Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundImage: widget.userImageUrl.isNotEmpty
                  ? NetworkImage(widget.userImageUrl)
                  : null,
              child: widget.userImageUrl.isEmpty
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(height: 16),

            // User Name
            Text(
              widget.userName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Report Reason
            Text(
              'Report Reason: ${widget.reportReason}',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),

            // Reporter Details
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      Text(
                        'Reported By: $reporterName',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Report Date: $formattedDate',
                        style: const TextStyle(fontSize: 14),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtherUserProfilePage(
                                userId: widget.reportedById, // <- IMPORTANT
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.person),
                        label: const Text('View Profile - Reporter'),
                      ),
                    ],
                  ),

            const Divider(height: 40),

            // User Details
            Expanded(
              child: ListView(
                children: [
                  if (contactInfo.isNotEmpty)
                    ListTile(
                      title: const Text('Contact Details'),
                      subtitle: Text(contactInfo),
                    ),
                  ListTile(
                    title: const Text('Credibility Score'),
                    subtitle:
                        Text('${widget.userData['credibilityScore'] ?? 'N/A'}'),
                  ),
                  ListTile(
                    title: const Text('User Rating'),
                    subtitle: Text(
                      '${(widget.userData['rating'] ?? 0.0).toStringAsFixed(1)} '
                      '(${widget.userData['ratingCount'] ?? 0} ratings)',
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement alert functionality
                  },
                  child: const Text('Alert'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement freeze functionality
                  },
                  child: const Text('Freeze'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    // TODO: Implement ban functionality
                  },
                  child: const Text('Ban'),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OtherUserProfilePage(
                      userId: widget.userData['id'], // <- IMPORTANT
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.person),
              label: const Text('View Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
