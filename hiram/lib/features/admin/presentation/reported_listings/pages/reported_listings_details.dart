import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'reported_listings_service.dart';
import '../../../../listing/model/listing_model.dart';
import '../../../../listing/presentation/listing_details.dart';
import '../../../../user_profile/presentation/otheruser_page.dart';
import '../actions/admin_listing_actions.dart';

class ReportedListingsDetails extends StatefulWidget {
  final Map<String, dynamic> reportData;

  const ReportedListingsDetails({Key? key, required this.reportData})
      : super(key: key);

  @override
  State<ReportedListingsDetails> createState() =>
      _ReportedListingsDetailsState();
}

class _ReportedListingsDetailsState extends State<ReportedListingsDetails> {
  final ReportedListingsService _reportedListingsService =
      ReportedListingsService();

  Listing? _listing;
  String? _reporterName;
  bool _isLoading = true;
  String? _ownerId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final listingId = widget.reportData['listingId'];
    final reporterId = widget.reportData['reportedBy'];

    if (listingId != null) {
      final result =
          await _reportedListingsService.fetchListingAndOwner(listingId);
      if (mounted) {
        setState(() {
          _listing = result['listing'];
          _ownerId = result['ownerId'];
        });
      }
    }

    if (reporterId != null) {
      String fetchedReporterName =
          await _reportedListingsService.fetchReporterName(reporterId);
      if (mounted) {
        setState(() {
          _reporterName = fetchedReporterName;
        });
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reason = widget.reportData['reason'] ?? 'No reason provided';
    final reportedById = widget.reportData['reportedBy'] ?? 'Unknown user';
    final reportedAtTimestamp = widget.reportData['timestamp'];
    final reportedAt = reportedAtTimestamp != null
        ? (reportedAtTimestamp.toDate() as DateTime)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_listing != null) ...[
                    Text(
                      _listing!.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _listing!.images.isNotEmpty
                        ? CarouselSlider(
                            options: CarouselOptions(
                              height: 200,
                              enlargeCenterPage: true,
                              enableInfiniteScroll: true,
                              autoPlay: true,
                            ),
                            items: _listing!.images.map((imageUrl) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  imageUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                    'assets/images/placeholder.png',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        : Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.image,
                                size: 80, color: Colors.grey),
                          ),
                    const SizedBox(height: 20),
                  ],
                  const Text('Reason:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(reason),
                  const SizedBox(height: 20),
                  if (_listing != null)
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
                  const Divider(
                    height: 40,
                  ),
                  const SizedBox(height: 12),
                  const Text('Reported By:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(_reporterName ?? 'Loading...'),
                  const SizedBox(height: 12),
                  if (reportedAt != null) ...[
                    const Text('Reported At:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                        '${reportedAt.day}/${reportedAt.month}/${reportedAt.year} ${reportedAt.hour}:${reportedAt.minute}'),
                  ],
                  const SizedBox(height: 16),
                  if (_reporterName != null)
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OtherUserProfilePage(
                                userId: reportedById,
                              ),
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
                  const Divider(
                    height: 40,
                  ),
                  const SizedBox(height: 24),
                  if (_listing != null && _ownerId != null)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              AdminListingActions.showAlert(
                                context: context,
                                receiverId: _ownerId!,
                                listing: _listing!,
                                reason: reason,
                              );
                            },
                            icon: const Icon(Icons.warning_amber_rounded),
                            label: const Text('Alert'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              AdminListingActions.toggleHideListing(
                                context: context,
                                listing: _listing!,
                                listingId: _listing!.id,
                                ownerId: _ownerId!,
                                reason: reason,
                              );
                            },
                            icon: Icon(_listing!.visibility == 'hidden'
                                ? Icons.visibility
                                : Icons.visibility_off),
                            label: Text(_listing!.visibility == 'hidden'
                                ? 'Unhide'
                                : 'Hide'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              AdminListingActions.deleteListing(
                                context: context,
                                listing: _listing!,
                                listingId: _listing!.id,
                                ownerId: _ownerId!,
                                reason: reason,
                              );
                            },
                            icon: const Icon(Icons.delete_forever),
                            label: const Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}
