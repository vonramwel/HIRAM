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

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    User? user = _auth.currentUser;
    if (user != null) {
      Map<String, dynamic>? userData =
          await _databaseMethods.getUserData(user.uid);
      if (userData != null && mounted) {
        setState(() {
          _userName = userData['name'] ?? 'Unknown User';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const CircleAvatar(radius: 40, backgroundColor: Colors.grey),
          const SizedBox(height: 10),
          Text(_userName,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
