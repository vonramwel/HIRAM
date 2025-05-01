import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hiram/features/inbox/presentation/inbox_page.dart';
import '../../user_profile/presentation/userprofile_header.dart';
import '../../user_profile/presentation/userprofile_page.dart';
import '../../explore/presentation/explore_page.dart';
import '../../listing/widgets/listings_section.dart';
import '../../listing/presentation/add_listing.dart';
import '../../transaction/presentation/transactions_section.dart';
import '../../auth/service/database.dart';
import '../../auth/presentation/login_page.dart'; // Import your login screen

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _currentIndex = 0;
  bool isAccountLocked = false;

  @override
  void initState() {
    super.initState();
    _checkAccountStatus();
  }

  Future<void> _checkAccountStatus() async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isNotEmpty) {
      Map<String, dynamic>? userData = await DatabaseMethods().getUserData(uid);
      if (userData != null && userData['accountStatus'] == 'locked') {
        setState(() {
          isAccountLocked = true;
        });
      }
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B2B2B), // Dark color
        elevation: 0,
        title: const Text(
          'Hiram',
          style: TextStyle(
            color: Colors.white, // Light text on dark background
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _buildPage(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color(0xFFFFFFFF),
        selectedItemColor: const Color(0xFF2B2B2B),
        unselectedItemColor: const Color(0xFFB3B3B3),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Inbox'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return Scaffold(
            floatingActionButton: isAccountLocked
                ? null
                : FloatingActionButton(
                    backgroundColor: const Color(0xFF2B2B2B),
                    child: const Icon(Icons.add, color: Color(0xFFFFFFFF)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddListingPage()),
                      );
                    },
                  ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserProfile(),
                  const SizedBox(height: 10),
                  if (!isAccountLocked) ListingsSection(title: 'Products'),
                  const SizedBox(height: 10),
                  if (!isAccountLocked) ListingsSection(title: 'Services'),
                ],
              ),
            ));

      case 1:
        return ExplorePage();
      case 2:
        return SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // UserProfile(),
            TransactionsSection(),
          ],
        ));
      case 3:
        return const InboxPage();
      case 4:
        return const UserProfilePage();
      default:
        return const Center(child: Text('Page not found'));
    }
  }
}
