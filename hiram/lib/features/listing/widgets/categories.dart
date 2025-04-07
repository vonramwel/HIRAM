import 'package:flutter/material.dart';
import '../presentation/category_listings_page.dart'; // Import the new page

class Categories extends StatefulWidget {
  final String type; // 'Products' or 'Services'

  const Categories({Key? key, required this.type}) : super(key: key);

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  List<Map<String, dynamic>> allCategories = [
    {'name': 'Electronics & Gadgets', 'icon': Icons.electrical_services},
    {'name': 'Vehicles & Transportation', 'icon': Icons.directions_car},
    {'name': 'Home & Appliances', 'icon': Icons.kitchen},
    {'name': 'Furniture & Decor', 'icon': Icons.weekend},
    {'name': 'Clothing & Accessories', 'icon': Icons.checkroom},
    {'name': 'Sports & Outdoor Equipment', 'icon': Icons.sports_soccer},
    {'name': 'Tools & Machinery', 'icon': Icons.build},
    {'name': 'Musical Instruments', 'icon': Icons.music_note},
    {'name': 'Books & Learning Materials', 'icon': Icons.book},
    {'name': 'Home Services', 'icon': Icons.home_repair_service},
    {'name': 'Event & Party Services', 'icon': Icons.event},
    {'name': 'Personal Services', 'icon': Icons.spa},
    {'name': 'Professional & Technical Services', 'icon': Icons.work},
    {'name': 'Vehicle & Transport Services', 'icon': Icons.local_shipping},
  ];

  @override
  Widget build(BuildContext context) {
    // Determine which categories to show based on type
    List<Map<String, dynamic>> filteredCategories;
    if (widget.type == 'Products') {
      filteredCategories = allCategories.sublist(0, 9); // First 9 are products
    } else {
      filteredCategories = allCategories.sublist(9); // Remaining are services
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filteredCategories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryListingsPage(
                    category: filteredCategories[index]['name'],
                    type: widget.type,
                  ),
                ),
              );
              print(filteredCategories[index]['name']);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.black,
                    child: Icon(
                      filteredCategories[index]['icon'],
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 70,
                    child: Text(
                      filteredCategories[index]['name'],
                      style: const TextStyle(fontSize: 11.5),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
