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
  String userLabel = 'User'; // Default label
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  final AuthMethods _authMethods = AuthMethods();

  String formatDateTime(DateTime dateTime) {
    return DateFormat('MM-dd-yyyy hh:mm a').format(dateTime.toLocal());
  }

  Future<void> _fetchUserName(String userId) async {
    try {
      Map<String, dynamic>? userData =
          await _databaseMethods.getUserData(userId);
      if (mounted) {
        setState(() {
          userName = userData?['name'] ?? 'Unknown User';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          userName = 'Error loading user';
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
        final String renterId = widget.transaction.renterId ?? '';

        // Fetch owner or renter name based on the current user
        if (userName == 'Loading...' &&
            (ownerId.isNotEmpty || renterId.isNotEmpty)) {
          _authMethods.getCurrentUserId().then((currentUserId) {
            final String userToFetch =
                currentUserId == ownerId ? renterId : ownerId;
            setState(() {
              userLabel = currentUserId == ownerId
                  ? 'Renter'
                  : 'Owner'; // Update the label
            });
            _fetchUserName(userToFetch);
          });
        }

        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Left section: text info
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listingTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '$userLabel: $userName', // Dynamically display "Owner" or "Renter"
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start Date: ${formatDateTime(widget.transaction.startDate)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'End Date: ${formatDateTime(widget.transaction.endDate)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Middle section: image with errorBuilder
                Expanded(
                  flex: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      color: Colors.grey[200],
                      height: 60,
                      width: 60,
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                      child: Icon(Icons.image, size: 30)),
                            )
                          : const Center(child: Icon(Icons.image, size: 30)),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Right section: status and total
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Status:',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      Text(
                        widget.transaction.status.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Total:',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      Text(
                        'PHP ${widget.transaction.totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
