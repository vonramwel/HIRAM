import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/transaction_model.dart';
import '../../auth/service/auth.dart';
import '../../auth/service/database.dart';

class TransactionCard extends StatefulWidget {
  final TransactionModel transaction;
  final VoidCallback onTap;

  const TransactionCard({
    Key? key,
    required this.transaction,
    required this.onTap,
  }) : super(key: key);

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  String otherUserName = 'Loading...';
  String userLabel = 'User';
  bool isOtherUserLocked = false;

  bool isOwnerLocked = false;
  bool isRenterLocked = false;
  bool isOtherUserBanned = false;

  final DatabaseMethods _databaseMethods = DatabaseMethods();
  final AuthMethods _authMethods = AuthMethods();

  String formatDateTime(DateTime dateTime) {
    return DateFormat('MM-dd-yyyy hh:mm a').format(dateTime.toLocal());
  }

  String getUrgencyTag(DateTime startDate, DateTime endDate) {
    final now = DateTime.now();
    Duration diff;

    if (now.isBefore(startDate)) {
      diff = startDate.difference(now);
    } else if (now.isBefore(endDate)) {
      diff = endDate.difference(now);
    } else {
      return 'Expired';
    }

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min left';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hrs left';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days left';
    } else {
      return 'More than a week';
    }
  }

  Future<void> _fetchBanStatus(String ownerId, String renterId) async {
    try {
      final ownerData = await _databaseMethods.getUserData(ownerId);
      final renterData = await _databaseMethods.getUserData(renterId);

      final ownerStatus = ownerData?['accountStatus'] ?? '';
      final renterStatus = renterData?['accountStatus'] ?? '';

      setState(() {
        isOwnerLocked = ownerStatus == 'locked';
        isRenterLocked = renterStatus == 'locked';
      });

      final currentUserId = await _authMethods.getCurrentUserId();
      final isCurrentUserOwner = currentUserId == ownerId;
      final otherUserData = isCurrentUserOwner ? renterData : ownerData;
      final otherUserStatus = otherUserData?['accountStatus'] ?? '';

      setState(() {
        otherUserName = otherUserData?['name'] ?? 'Unknown User';
        userLabel = isCurrentUserOwner ? 'Renter' : 'Owner';
        isOtherUserLocked = otherUserStatus == 'locked';
        isOtherUserBanned = otherUserStatus == 'banned';
      });
    } catch (e) {
      setState(() {
        otherUserName = 'Error loading user';
        isOtherUserLocked = false;
        isOtherUserBanned = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('listings')
          .doc(widget.transaction.listingId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: const Text("Listing not found"),
              subtitle: Text("Transaction ID: ${widget.transaction.listingId}"),
            ),
          );
        }

        final listingData = snapshot.data!.data() as Map<String, dynamic>;
        final images = listingData['images'] as List<dynamic>?;
        final imageUrl =
            (images != null && images.isNotEmpty) ? images[0] as String : '';
        final listingTitle = listingData['title'] ?? 'Listing Title';
        final ownerId = listingData['userId'] ?? '';
        final renterId = widget.transaction.renterId;

        final isDeleted = listingData['visibility'] == "deleted";
        final isHidden = listingData['visibility'] == "hidden";

        if (otherUserName == 'Loading...' &&
            (ownerId.isNotEmpty && renterId.isNotEmpty)) {
          _fetchBanStatus(ownerId, renterId);
        }

        final urgency = getUrgencyTag(
          widget.transaction.startDate,
          widget.transaction.endDate,
        );

        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Listing Title + Indicator
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        listingTitle,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isDeleted)
                      _buildTag('DELETED', Colors.red)
                    else if (isHidden)
                      _buildTag('HIDDEN', Colors.orange),
                  ],
                ),
                const SizedBox(height: 4),

                // Username + Ban Status
                Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '$userLabel: $otherUserName',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isOtherUserLocked || isOtherUserBanned
                            ? Colors.red
                            : Colors.grey[700],
                      ),
                    ),
                    if (isOtherUserBanned) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.warning, color: Colors.red, size: 16),
                      const Text(
                        'BANNED',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ] else if (isOtherUserLocked) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.lock, color: Colors.orange, size: 16),
                      const Text(
                        'LOCKED',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 12),

                // Image + Status + Price + Urgency
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Listing image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 70,
                        width: 70,
                        color: Colors.grey[200],
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                        child: Icon(Icons.broken_image)),
                              )
                            : const Center(child: Icon(Icons.image, size: 30)),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Status and Price
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Status
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.transaction.status.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                              // Price
                              Text(
                                'PHP ${widget.transaction.totalPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Urgency Tag
                          Align(
                            alignment: Alignment.centerRight,
                            child: _buildTag(
                              urgency,
                              urgency == 'Expired'
                                  ? Colors.grey
                                  : urgency.contains('min')
                                      ? Colors.red
                                      : urgency.contains('hrs')
                                          ? Colors.orange
                                          : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Date Range
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      '${formatDateTime(widget.transaction.startDate)} - ${formatDateTime(widget.transaction.endDate)}',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
