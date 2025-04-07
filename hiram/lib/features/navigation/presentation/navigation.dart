import 'package:flutter/material.dart';
import '../../listing/widgets/user_profile.dart';
import '../../listing/widgets/categories.dart';
import '../../listing/widgets/listings_section.dart';
import '../../listing/presentation/add_listing.dart';
// import 'explore_page.dart';
import '../../transaction/presentation/transactions_section.dart';
// import 'inbox_page.dart';
// import 'profile_page.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _currentIndex = 0; // Default to HomePage

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hiram'),
      ),
      body: _buildPage(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.black,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home, color: Colors.black), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.search, color: Colors.black), label: 'Explore'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart, color: Colors.black),
              label: 'Transactions'),
          BottomNavigationBarItem(
              icon: Icon(Icons.message, color: Colors.black), label: 'Inbox'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person, color: Colors.black), label: 'Profile'),
        ],
      ),
    );
  }

  /// Builds the page content dynamically based on the selected index.
  Widget _buildPage(int index) {
    switch (index) {
      case 0: // Home Page
        return Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddListingPage()),
                );
              },
              child: const Icon(Icons.add),
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserProfile(),
                  SizedBox(height: 10),
                  ListingsSection(title: 'Products'),
                  // Categories(),
                  SizedBox(height: 20),
                  //Categories(),
                  ListingsSection(title: 'Services'),
                ],
              ),
            ));

      case 1:
        return const UserProfile();
      case 2:
        return SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          UserProfile(),
          Text('Lender'),
          TransactionsSection(title: 'Transactions as Lender'),
          Text('Renter'),
          TransactionsSection(title: 'Transactions as Renter'),
        ]));
      case 3:
        return const ListingsSection(title: 'Products');
      case 4:
        return const UserProfile();
      default:
        return const Center(child: Text('Page not found'));
    }
  }
}
