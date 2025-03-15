import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
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
