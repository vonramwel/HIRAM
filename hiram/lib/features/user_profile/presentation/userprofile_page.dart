import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/service/database.dart';
import '../service/analytics_service.dart';
import '../../listing/model/listing_model.dart';
import '../../listing/widgets/listing_card.dart';
import 'userprofile_details.dart';
import 'mylistings_page.dart';
import 'archived_listings_page.dart'; // <--- NEW import

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  final TransactionHelpers _transactionHelpers = TransactionHelpers();

  String _userName = 'Loading...';
  String _phone = '';
  String _address = '';
  String _bio = '';
  int _completedTransactions = 0;
  int _activeTransactions = 0;
  int _pendingTransactions = 0;
  double _totalExpenses = 0.0;
  String _profileImageUrl = '';
  double _rating = 0.0;
  double _totalRevenue = 0.0;

  late TextEditingController _bioController;
  List<Listing> _topListings = [];
  final Map<String, String> preloadedUserNames = {}; // Cache for usernames

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userData = await _databaseMethods.getCurrentUserData();
    final completedTx =
        await _transactionHelpers.getCompletedTransactionCountForCurrentUser();
    final activeTx =
        await _transactionHelpers.getActiveTransactionCountForCurrentUser();
    final pendingTx =
        await _transactionHelpers.getPendingTransactionCountForCurrentUser();
    final rating = await _transactionHelpers.getUserRating();
    final totalRevenue =
        await _transactionHelpers.getTotalRevenueForCurrentUser();
    final totalExpenses =
        await _transactionHelpers.getTotalExpensesForCurrentUser();
    final topListingsData =
        await _transactionHelpers.getTopUserListingsByRating(limit: 2);

    if (userData != null && mounted) {
      setState(() {
        _userName = userData['name'] ?? 'Unknown User';
        _phone = userData['contactNumber'] ?? '';
        _address = userData['address'] ?? '';
        _bio = userData['bio'] ?? '';
        _bioController.text = _bio;
        _profileImageUrl = userData['imgUrl'] ?? '';
        _rating = rating ?? 0.0;
        _completedTransactions = completedTx;
        _activeTransactions = activeTx;
        _pendingTransactions = pendingTx;
        _totalRevenue = totalRevenue;
        _totalExpenses = totalExpenses;
        _topListings = topListingsData
            .map<Listing>((data) => Listing.fromMap(data))
            .where((listing) =>
                listing.visibility != 'archived' &&
                listing.visibility != 'deleted') // <--- FILTER HERE
            .toList();
      });

      await preloadUserNames(_topListings);
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> preloadUserNames(List<Listing> listings) async {
    final uniqueUserIds = listings.map((l) => l.userId).toSet();

    for (String userId in uniqueUserIds) {
      if (!preloadedUserNames.containsKey(userId)) {
        final userDoc = await FirebaseFirestore.instance
            .collection('User')
            .doc(userId)
            .get();
        if (userDoc.exists) {
          preloadedUserNames[userId] =
              userDoc.data()?['name'] ?? 'Unknown User';
        } else {
          preloadedUserNames[userId] = 'Unknown User';
        }
      }
    }
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserProfileDetails()),
                      );
                    },
                    child: const Text(
                      'VIEW PROFILE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: _profileImageUrl.isNotEmpty
                    ? NetworkImage(_profileImageUrl)
                    : null,
                child: _profileImageUrl.isEmpty
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 10),
              Text(
                _userName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_phone.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(_phone, style: const TextStyle(color: Colors.black54)),
              ],
              if (_address.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(_address, style: const TextStyle(color: Colors.black45)),
              ],
              const SizedBox(height: 10),
              TextField(
                controller: _bioController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Add Bio...',
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2,
                children: [
                  _buildStatCard(
                      'Number of Active Transactions', '$_activeTransactions'),
                  _buildStatCard('Number of Pending Transactions',
                      '$_pendingTransactions'),
                  _buildStatCard('Number of Completed Transactions',
                      '$_completedTransactions'),
                  _buildStatCard(
                      'User Rating', '${_rating.toStringAsFixed(1)} / 5.0'),
                  _buildStatCard(
                      'Total Earnings', '₱${_totalRevenue.toStringAsFixed(2)}'),
                  _buildStatCard('Total Expenses',
                      '₱${_totalExpenses.toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Top Listings',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyListingsPage()),
                      );
                    },
                    child: const Text(
                      'VIEW ALL LISTINGS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _topListings
                      .map((listing) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ListingCard(
                              listing: listing,
                              userName: preloadedUserNames[listing.userId] ??
                                  'Loading...',
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ArchivedListingsPage(),
                    ),
                  );
                },
                child: const Text('VIEW ALL ARCHIVED LISTINGS'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
