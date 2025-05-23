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
  String? _accountStatus;

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
        _accountStatus = userData['accountStatus'] ?? 'active';
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
        height: 100,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2B2B2B), // dark gray background
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFD4D4D4), // light gray text
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFFFFFFFF), // white for values
                  fontSize: 15,
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
            backgroundColor: const Color(0xFFB3B3B3), // medium gray
            backgroundImage: _profileImageUrl.isNotEmpty
                ? NetworkImage(_profileImageUrl)
                : null,
            child: _profileImageUrl.isEmpty
                ? const Icon(Icons.person, size: 40, color: Color(0xFFFFFFFF))
                : null,
          ),
          const SizedBox(height: 10),
          Text(
            _userName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2B2B2B), // dark gray text
            ),
          ),
          if (_accountStatus == 'locked') ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFFFFE5E5), // soft red background
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock, color: Colors.red, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Account Locked',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatCard('Active Transactions', '$_activeTransactions'),
              const SizedBox(width: 8),
              _buildStatCard(
                'Rating',
                _userRating == 0.0
                    ? 'No Ratings'
                    : '${_userRating.toStringAsFixed(1)}/5.0',
              ),
              const SizedBox(width: 8),
              _buildStatCard('Pending Transactions', '$_pendingTransactions'),
            ],
          ),
        ],
      ),
    );
  }
}
