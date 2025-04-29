import 'package:flutter/material.dart';
import '../actions/admin_user_actions.dart';
import 'reported_user_service.dart';

class ReportCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final VoidCallback onTap;
  final String reportedUserId;

  const ReportCard({
    Key? key,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.onTap,
    required this.reportedUserId,
  }) : super(key: key);

  @override
  State<ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<ReportCard> {
  late Future<String> accountStatusFuture;

  @override
  void initState() {
    super.initState();
    accountStatusFuture = _getAccountStatus();
  }

  Future<String> _getAccountStatus() async {
    final userData =
        await AdminUserService.getUserDataById(widget.reportedUserId);
    return userData?['accountStatus'] ?? 'unknown';
  }

  void _handleAlert() async {
    final userData =
        await AdminUserService.getUserDataById(widget.reportedUserId);
    final reportedUserName = userData?['name'] ?? 'Unknown';

    AdminUserActions.showAlertDialog(
      context: context,
      receiverId: widget.reportedUserId,
      receiverName: reportedUserName,
    );
  }

  void _handleFreezeOrUnfreeze(String action) {
    AdminUserActions.performFreezeOrUnfreezeAction(
      userId: widget.reportedUserId,
      context: context,
      action: action,
    );
  }

  void _handleBan() {
    AdminUserActions.performBanAction();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: accountStatusFuture,
      builder: (context, snapshot) {
        final isLocked = snapshot.data == 'locked';
        final freezeActionLabel = isLocked ? 'Unfreeze' : 'Freeze';
        final freezeOrUnfreezeAction = isLocked ? 'unfreeze' : 'freeze';

        return Card(
          child: ListTile(
            onTap: widget.onTap,
            leading: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                ? CircleAvatar(
                    backgroundImage: NetworkImage(widget.imageUrl!),
                  )
                : const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
            title: Text(widget.title),
            subtitle: Text(widget.subtitle),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'Alert') _handleAlert();
                if (value == 'FreezeOrUnfreeze')
                  _handleFreezeOrUnfreeze(freezeOrUnfreezeAction);
                if (value == 'Ban') _handleBan();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'Alert', child: Text('Alert')),
                PopupMenuItem(
                    value: 'FreezeOrUnfreeze', child: Text(freezeActionLabel)),
                const PopupMenuItem(value: 'Ban', child: Text('Ban')),
              ],
            ),
          ),
        );
      },
    );
  }
}
