import 'package:flutter/material.dart';
import '../../auth/service/database.dart';
import '../service/analytics_service.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  final TransactionHelpers _analyticsService = TransactionHelpers();

  String _userName = 'Loading...';
  String _profileImageUrl = '';

  int _activeTransactions = 0;
  int _pendingTransactions = 0;
  double _userRating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAnalyticsData();
  }

  Future<void> _loadUserData() async {
    Map<String, dynamic>? userData =
        await _databaseMethods.getCurrentUserData();
    if (userData != null && mounted) {
      setState(() {
        _userName = userData['name'] ?? 'Unknown User';
        _profileImageUrl = userData['imgUrl'] ?? '';
      });
    }
  }

  Future<void> _loadAnalyticsData() async {
    final active =
        await _analyticsService.getActiveTransactionCountForCurrentUser();
    final pending =
        await _analyticsService.getPendingTransactionCountForCurrentUser();
    final rating = await _analyticsService.getUserRating();

    if (mounted) {
      setState(() {
        _activeTransactions = active;
        _pendingTransactions = pending;
        _userRating = rating ?? 0.0;
      });
    }
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: SizedBox(
        height: 100, // Set a fixed height for consistency
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey,
            backgroundImage: _profileImageUrl.isNotEmpty
                ? NetworkImage(_profileImageUrl)
                : null,
            child: _profileImageUrl.isEmpty
                ? const Icon(Icons.person, size: 40, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 10),
          Text(
            _userName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatCard('Active Transactions', '$_activeTransactions'),
              const SizedBox(width: 8),
              _buildStatCard(
                  'User Rating', '${_userRating.toStringAsFixed(1)}/ 5.0'),
              const SizedBox(width: 8),
              _buildStatCard('Pending Transactions', '$_pendingTransactions'),
            ],
          ),
        ],
      ),
    );
  }
}
