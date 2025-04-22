import 'package:flutter/material.dart';
import '../../auth/service/database.dart';
import 'userprofile_details.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final DatabaseMethods _databaseMethods = DatabaseMethods();

  String _userName = 'Loading...';
  String _phone = '';
  String _address = '';
  String _bio = '';
  int _itemsRentedOut = 0;
  int _itemsRenting = 0;
  double _credibilityScore = 0.0;
  String _profileImageUrl = '';
  late TextEditingController _bioController;

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
    Map<String, dynamic>? userData =
        await _databaseMethods.getCurrentUserData();
    if (userData != null && mounted) {
      setState(() {
        _userName = userData['name'] ?? 'Unknown User';
        _phone = userData['contactNumber'] ?? '';
        _address = userData['address'] ?? '';
        _bio = userData['bio'] ?? '';
        _bioController.text = _bio;
        _itemsRentedOut = userData['itemsRentedOut'] ?? 0;
        _itemsRenting = userData['itemsRenting'] ?? 0;
        _credibilityScore = (userData['credibilityScore'] ?? 0).toDouble();
        _profileImageUrl = userData['imgUrl'] ?? '';
      });
    }
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
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
    );
  }

  Widget _buildTopListingCard() {
    return Container(
      width: 150,
      height: 150,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 50, color: Colors.grey),
            SizedBox(height: 8),
            Text("Listing Name", style: TextStyle(color: Colors.grey)),
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
                Text(
                  _phone,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
              if (_address.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  _address,
                  style: const TextStyle(color: Colors.black45),
                ),
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
                  _buildStatCard('Number of Items Lent', '$_itemsRentedOut'),
                  _buildStatCard('Number of Items Renting', '$_itemsRenting'),
                  _buildStatCard('Revenue', '100,000'),
                  _buildStatCard('User Credibility Score',
                      '${_credibilityScore.toStringAsFixed(0)}%'),
                  _buildStatCard('Rental Duration Statistics', 'nnn'),
                  _buildStatCard('Number of Completed Transactions', '10'),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Top Listings',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'VIEW ALL LISTINGS',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTopListingCard(),
                  _buildTopListingCard(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
