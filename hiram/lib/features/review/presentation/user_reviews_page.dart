import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/service/database.dart'; // make sure this path is correct

class RenterReviewDetailsPage extends StatefulWidget {
  final String renterId;
  final String ownerId;
  const RenterReviewDetailsPage({
    super.key,
    required this.renterId,
    required this.ownerId,
  });

  @override
  State<RenterReviewDetailsPage> createState() =>
      _RenterReviewDetailsPageState();
}

class _RenterReviewDetailsPageState extends State<RenterReviewDetailsPage> {
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  String renterName = 'Loading...';
  Map<String, String> lenderNames = {}; // Cache for lender names

  @override
  void initState() {
    super.initState();
    _loadRenterName();
  }

  Future<void> _loadRenterName() async {
    try {
      Map<String, dynamic>? renterData =
          await _databaseMethods.getUserData(widget.renterId);
      setState(() {
        renterName = renterData?['name'] ?? 'Unknown Renter';
      });
    } catch (e) {
      setState(() {
        renterName = 'Error loading name';
      });
    }
  }

  Future<String> _getLenderName(String lenderId) async {
    if (lenderNames.containsKey(lenderId)) {
      return lenderNames[lenderId]!;
    }

    try {
      Map<String, dynamic>? data = await _databaseMethods.getUserData(lenderId);
      final name = data?['name'] ?? 'Unknown Lender';
      lenderNames[lenderId] = name;
      return name;
    } catch (e) {
      return 'Error loading name';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reviews for $renterName")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Reviews')
            .where('renterId', isEqualTo: widget.renterId)
            .where('reviewedBy', isEqualTo: 'lender')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No reviews from lenders.'));
          }

          final reviews = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index].data() as Map<String, dynamic>;
              final lenderId = review['lenderId'];

              return FutureBuilder<String>(
                future: _getLenderName(lenderId),
                builder: (context, snapshot) {
                  final lenderName = snapshot.data ?? 'Loading...';

                  return Card(
                    margin: const EdgeInsets.all(10),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lenderName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
