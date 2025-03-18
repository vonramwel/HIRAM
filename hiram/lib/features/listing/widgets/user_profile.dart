import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/service/database.dart'; // Import DatabaseMethods

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  String _userName = 'Loading...';
  int _itemsRentedOut = 0;
  int _itemsRenting = 0;
  double _credibilityScore = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      Map<String, dynamic>? userData =
          await _databaseMethods.getUserData(user.uid);
      if (userData != null && mounted) {
        setState(() {
          _userName = userData['name'] ?? 'Unknown User';
          _itemsRentedOut = userData['itemsRentedOut'] ?? 0;
          _itemsRenting = userData['itemsRenting'] ?? 0;
          _credibilityScore = userData['credibilityScore'] ?? 0.0;
        });
      }
    }
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
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
            const SizedBox(height: 5),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const CircleAvatar(radius: 40, backgroundColor: Colors.grey),
          const SizedBox(height: 10),
          Text(
            _userName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard('Number of Items\nRented Out', '$_itemsRentedOut'),
              _buildStatCard('User Credibility\nScore',
                  '${_credibilityScore.toStringAsFixed(0)}%'),
              _buildStatCard('Number of Items\nRenting', '$_itemsRenting'),
            ],
          ),
        ],
      ),
    );
  }
}
