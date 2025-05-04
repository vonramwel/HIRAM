import 'package:flutter/material.dart';
import 'reported_transactions_service.dart';
import '../../../transaction/model/transaction_model.dart';
import '../../../listing/model/listing_model.dart';
import '../../../listing/presentation/listing_details.dart';
import '../../../user_profile/presentation/otheruser_page.dart';

class ReportedTransactionsDetails extends StatefulWidget {
  final Map<String, dynamic> reportData;

  const ReportedTransactionsDetails({Key? key, required this.reportData})
      : super(key: key);

  @override
  State<ReportedTransactionsDetails> createState() =>
      _ReportedTransactionsDetailsState();
}

class _ReportedTransactionsDetailsState
    extends State<ReportedTransactionsDetails> {
  final ReportedTransactionsService _service = ReportedTransactionsService();

  TransactionModel? _transaction;
  Listing? _listing;
  String _reporterName = 'Loading...';
  String? _reporterId;
  bool _isReporterSeller = false;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final transactionId = widget.reportData['transactionId'];
    final reporterId = widget.reportData['reportedBy'];

    final transaction = await _service.getTransactionDetails(transactionId);
    final listing = transaction != null
        ? await _service.getListingDetails(transaction.listingId)
        : null;
    final reporter = await _service.getReporterDetails(reporterId);

    if (mounted) {
      setState(() {
        _transaction = transaction;
        _listing = listing;
        _reporterId = reporterId;
        _reporterName = reporter?['name'] ?? 'Unknown Reporter';
        _isReporterSeller = reporterId == listing?.userId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reason = widget.reportData['reason'] ?? 'No reason provided';
    final timestamp = widget.reportData['timestamp'];
    final reportedAt =
        timestamp != null ? (timestamp.toDate() as DateTime) : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Reported Transaction Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: (_transaction == null || _listing == null)
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Listing Title: ${_listing!.title}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ListingDetailsPage(listing: _listing!),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('View Listing'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Reported By: $_reporterName'),
                  Text(
                      'Role: ${_isReporterSeller ? "Seller (Owner)" : "Renter"}'),
                  const SizedBox(height: 10),
                  Text('Reason: $reason'),
                  if (reportedAt != null)
                    Text(
                      'Reported At: ${reportedAt.day}/${reportedAt.month}/${reportedAt.year} ${reportedAt.hour}:${reportedAt.minute}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                OtherUserProfilePage(userId: _reporterId!),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person),
                      label: const Text('View Reporter Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OtherUserProfilePage(
                                userId: _listing!.userId,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.store),
                        label: const Text('View Seller'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OtherUserProfilePage(
                                userId: _transaction!.renterId,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.person_outline),
                        label: const Text('View Renter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const Text('Transaction Details',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Status: ${_transaction!.status}'),
                  Text(
                      'Total Price: ₱${_transaction!.totalPrice.toStringAsFixed(2)}'),
                  if (_transaction!.offeredPrice != null)
                    Text(
                        'Offered Price: ₱${_transaction!.offeredPrice!.toStringAsFixed(2)}'),
                  const SizedBox(height: 20),
                  const Divider(),
                ],
              ),
      ),
    );
  }
}
