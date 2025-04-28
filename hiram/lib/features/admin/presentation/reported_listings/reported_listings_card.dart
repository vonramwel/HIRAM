// lib/reported_listing/reported_listings_card.dart
import 'package:flutter/material.dart';
import '../../../listing/model/listing_model.dart';
import 'reported_listings_service.dart';

class ReportedListingsCard extends StatefulWidget {
  final String listingId;
  final String reason;
  final VoidCallback onTap;

  const ReportedListingsCard({
    Key? key,
    required this.listingId,
    required this.reason,
    required this.onTap,
  }) : super(key: key);

  @override
  State<ReportedListingsCard> createState() => _ReportedListingsCardState();
}

class _ReportedListingsCardState extends State<ReportedListingsCard> {
  Listing? _listing;
  String? _ownerName;
  bool _isLoading = true;

  final ReportedListingsService _service = ReportedListingsService();

  @override
  void initState() {
    super.initState();
    _fetchListingAndOwner();
  }

  Future<void> _fetchListingAndOwner() async {
    try {
      final result = await _service.fetchListingAndOwner(widget.listingId);

      setState(() {
        _listing = result['listing'];
        _ownerName = result['ownerName'];
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching listing or owner: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_listing == null) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          title: const Text('Listing not found'),
          subtitle: Text(widget.reason),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: widget.onTap,
        ),
      );
    }

    String imageUrl = _listing!.images.isNotEmpty ? _listing!.images.first : '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image, size: 40),
                )
              : const Icon(Icons.image, size: 40),
        ),
        title: Text(
          _listing!.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Owner: $_ownerName'),
            const SizedBox(height: 4),
            Text('Reason: ${widget.reason}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: widget.onTap,
      ),
    );
  }
}
