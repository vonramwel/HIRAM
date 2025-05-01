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
  String userName = 'Loading...';
  String userLabel = 'User';
  bool isUserLocked = false;

  final DatabaseMethods _databaseMethods = DatabaseMethods();
  final AuthMethods _authMethods = AuthMethods();

  String formatDateTime(DateTime dateTime) {
    return DateFormat('MM-dd-yyyy hh:mm a').format(dateTime.toLocal());
  }

  Future<void> _fetchUserInfo(String userId) async {
    try {
      Map<String, dynamic>? userData =
          await _databaseMethods.getUserData(userId);
      if (mounted) {
        setState(() {
          userName = userData?['name'] ?? 'Unknown User';
          isUserLocked = (userData?['accountStatus'] ?? '') == 'locked';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          userName = 'Error loading user';
          isUserLocked = false;
        });
      }
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
        final List<dynamic>? images = listingData['images'] as List<dynamic>?;
        final String imageUrl =
            (images != null && images.isNotEmpty) ? images[0] as String : '';
        final String listingTitle = listingData['title'] ?? 'Listing Title';
        final String ownerId = listingData['userId'] ?? '';
        final String renterId = widget.transaction.renterId;

        if (userName == 'Loading...' &&
            (ownerId.isNotEmpty || renterId.isNotEmpty)) {
          _authMethods.getCurrentUserId().then((currentUserId) {
            final String userToFetch =
                currentUserId == ownerId ? renterId : ownerId;
            setState(() {
              userLabel = currentUserId == ownerId ? 'Renter' : 'Owner';
            });
            _fetchUserInfo(userToFetch);
          });
        }

        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUserLocked ? Colors.red[50] : Colors.white,
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
                // Listing Title
                Text(
                  listingTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Username
                Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '$userLabel: $userName',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isUserLocked ? Colors.red : Colors.grey[700],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Image + Status + Price
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
                      child: Row(
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
                          Row(
                            children: [
                              const Icon(Icons.monetization_on,
                                  size: 16, color: Colors.green),
                              const SizedBox(width: 4),
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
}
