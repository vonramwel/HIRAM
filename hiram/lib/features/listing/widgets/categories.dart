import 'package:flutter/material.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  final List<Map<String, dynamic>> categories = [
    {'name': 'Electronics & Gadgets', 'icon': Icons.devices},
    {'name': 'Vehicles & Transportation', 'icon': Icons.directions_car},
    {'name': 'Home & Appliances', 'icon': Icons.kitchen},
    {'name': 'Furniture & Decor', 'icon': Icons.chair},
    {'name': 'Clothing & Accessories', 'icon': Icons.shopping_bag},
    {'name': 'Sports & Outdoor Equipment', 'icon': Icons.sports_soccer},
    {'name': 'Tools & Machinery', 'icon': Icons.handyman},
    {'name': 'Musical Instruments', 'icon': Icons.music_note},
    {'name': 'Books & Learning Materials', 'icon': Icons.menu_book},
    {'name': 'Home Services', 'icon': Icons.cleaning_services},
    {'name': 'Event & Party Services', 'icon': Icons.celebration},
    {'name': 'Personal Services', 'icon': Icons.person},
    {'name': 'Professional & Technical Services', 'icon': Icons.work},
    {'name': 'Vehicle & Transport Services', 'icon': Icons.local_shipping},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const Text(
          //   'Categories',
          //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          // ),
          const SizedBox(height: 10),
          SizedBox(
            height: 90, // 🔹 Increased height to prevent overflow
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min, // Prevents extra space issues
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.black,
                        child: Icon(
                          categories[index]['icon'],
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: 65, // 🔹 Slightly wider for better readability
                        child: Text(
                          categories[index]['name'],
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
