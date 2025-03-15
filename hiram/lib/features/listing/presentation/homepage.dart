import 'package:flutter/material.dart';
import '../model/listing_model.dart';
import '../service/listing_service.dart';
import 'add_listing.dart';
import 'listing_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/service/database.dart'; // Import DatabaseMethods

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ListingService _listingService = ListingService();
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _userName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    User? user = _auth.currentUser;
    if (user != null) {
      print(user.uid);
      Map<String, dynamic>? userData =
          await _databaseMethods.getUserData(user.uid);
      if (userData != null && mounted) {
        setState(() {
          _userName = userData['name'] ?? 'Unknown User';
        });
      } else {
        setState(() {
          _userName = 'Unknown User';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context)
                .size
                .height, // Ensure it takes full height
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserProfile(),
              _buildCategories(),
              _buildListingsSection('Products'),
              _buildListingsSection('Services'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddListingPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUserProfile() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const CircleAvatar(radius: 40, backgroundColor: Colors.grey),
          const SizedBox(height: 10),
          Text(_userName,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: _infoCard('Number of Items Rented Out', '100'),
              ),
              Flexible(
                child: _infoCard('User Credibility Score', '90%'),
              ),
              Flexible(
                child: _infoCard('Number of Items Renting', '1'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Expanded(
      child: Card(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
              const SizedBox(height: 5),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5, // Replace with actual categories
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      CircleAvatar(radius: 20, backgroundColor: Colors.grey),
                      const SizedBox(height: 5),
                      const Text('Category',
                          style: TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingsSection(String title) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 300, // Adjust this height as needed
              child: StreamBuilder<List<Listing>>(
                stream: _listingService.getListings(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No listings available.'));
                  }

                  final listings = snapshot.data!
                      .where((listing) =>
                          (title == 'Products' &&
                              listing.type == 'Products for Rent') ||
                          (title == 'Services' &&
                              listing.type != 'Products for Rent'))
                      .toList();

                  if (listings.isEmpty) {
                    return const Center(child: Text('No listings available.'));
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: listings.length,
                    itemBuilder: (context, index) {
                      final listing = listings[index];
                      return _listingCard(context, listing);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listingCard(BuildContext context, Listing listing) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListingDetailsPage(listing: listing),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  'https://via.placeholder.com/150', // Replace with listing.imageUrl if available
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '₱${listing.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                      const Spacer(),
                      const Icon(Icons.star_border, color: Colors.amber),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.black, // Set a solid color (e.g., white)
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
    );
  }
}
