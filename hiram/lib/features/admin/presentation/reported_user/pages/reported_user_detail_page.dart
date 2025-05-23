import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../user_profile/presentation/otheruser_page.dart';
import '../actions/admin_user_actions.dart';
import 'reported_user_service.dart';

class ReportedUserDetailPage extends StatefulWidget {
  final String userName;
  final String userImageUrl;
  final String reportReason;
  final Map<String, dynamic> userData;
  final String reportedById;
  final Timestamp? reportTimestamp;

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
  String accountStatus = 'normal';

  @override
  void initState() {
    super.initState();
    fetchReporterName();
    fetchAccountStatus();
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

  Future<void> fetchAccountStatus() async {
    final userData =
        await AdminUserService.getUserDataById(widget.userData['id']);
    final rawStatus =
        userData?['accountStatus']?.toString().toLowerCase().trim();
    setState(() {
      accountStatus = rawStatus == 'locked' ? 'locked' : 'normal';
    });
  }

  void _handleAlert() async {
    final userData =
        await AdminUserService.getUserDataById(widget.userData['id']);
    final reportedUserName = userData?['name'] ?? 'Unknown';

    AdminUserActions.showAlertDialog(
      context: context,
      receiverId: widget.userData['id'],
      receiverName: reportedUserName,
    );
  }

  void _handleFreezeOrUnfreeze() async {
    final action = accountStatus == 'locked' ? 'unfreeze' : 'freeze';

    await AdminUserActions.performFreezeOrUnfreezeAction(
      userId: widget.userData['id'],
      context: context,
      action: action,
    );

    await fetchAccountStatus();
  }

  void _handleBan() {
    AdminUserActions.performBanAction(
      userId: widget.userData['id'],
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
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

    final isLocked = accountStatus == 'locked';
    final freezeLabel = isLocked ? 'Unfreeze' : 'Freeze';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reported User Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
            Text(
              widget.userName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Report Reason: ${widget.reportReason}',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OtherUserProfilePage(
                      userId: widget.userData['id'],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.person),
              label: const Text('View Profile'),
            ),
            // const SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: [
                  if (contactInfo.isNotEmpty)
                    ListTile(
                      title: const Text('Contact Details'),
                      subtitle: Text(contactInfo),
                    ),
                  // ListTile(
                  //   title: const Text('Credibility Score'),
                  //   subtitle:
                  //       Text('${widget.userData['credibilityScore'] ?? 'N/A'}'),
                  // ),
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
            const Divider(height: 40),
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
                                userId: widget.reportedById,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.person),
                        label: const Text('View Profile - Reporter'),
                      ),
                    ],
                  ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _handleAlert,
                  child: const Text('Alert'),
                ),
                ElevatedButton(
                  onPressed: _handleFreezeOrUnfreeze,
                  child: Text(freezeLabel),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: _handleBan,
                  child: const Text('Ban'),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
