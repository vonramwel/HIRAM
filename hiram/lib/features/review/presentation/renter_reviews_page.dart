import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/service/database.dart';

class RenterReviewsPage extends StatefulWidget {
  final String listingId;

  const RenterReviewsPage({super.key, required this.listingId});

  @override
  State<RenterReviewsPage> createState() => _RenterReviewsPageState();
}

class _RenterReviewsPageState extends State<RenterReviewsPage> {
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  final Map<String, String> _renterNamesCache = {};

  Future<String> _getRenterName(String renterId) async {
    if (_renterNamesCache.containsKey(renterId)) {
      return _renterNamesCache[renterId]!;
    }

    final userData = await _databaseMethods.getUserData(renterId);
    final name = userData?['name'] ?? 'Unknown User';
    _renterNamesCache[renterId] = name;
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reviews by Renters"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Reviews')
            .where('listingId', isEqualTo: widget.listingId)
            .where('reviewedBy', isEqualTo: 'renter')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No reviews by renters.'));
          }

          final reviews = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index].data() as Map<String, dynamic>;
              final renterId = review['renterId'] ?? '';

              return FutureBuilder<String>(
                future: _getRenterName(renterId),
                builder: (context, nameSnapshot) {
                  final renterName = nameSnapshot.data ?? 'Loading...';

                  return Card(
                    margin: const EdgeInsets.all(10),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            renterName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: List.generate(
                              review['rating'] ?? 0,
                              (i) =>
                                  const Icon(Icons.star, color: Colors.amber),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(review['comment'] ?? ''),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
