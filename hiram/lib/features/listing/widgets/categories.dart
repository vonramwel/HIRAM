import 'package:flutter/material.dart';
import '../presentation/category_listings_page.dart';

class Categories extends StatefulWidget {
  final String type; // 'Products' or 'Services'

  const Categories({Key? key, required this.type}) : super(key: key);

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  // Full category names used for filtering
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

  // Shortened display names only for UI
  final Map<String, String> shortCategoryNames = {
    'Electronics & Gadgets': 'Electronics',
    'Vehicles & Transportation': 'Vehicles',
    'Home & Appliances': 'Appliances',
    'Furniture & Decor': 'Furniture',
    'Clothing & Accessories': 'Clothing',
    'Sports & Outdoor Equipment': 'Sports',
    'Tools & Machinery': 'Tools',
    'Musical Instruments': 'Instruments',
    'Books & Learning Materials': 'Books',
    'Home Services': 'Home',
    'Event & Party Services': 'Events',
    'Personal Services': 'Personal',
    'Professional & Technical Services': 'Professional',
    'Vehicle & Transport Services': 'Transport',
  };

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredCategories;
    if (widget.type == 'Products') {
      filteredCategories = allCategories.sublist(0, 9);
    } else {
      filteredCategories = allCategories.sublist(9);
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filteredCategories.length,
        itemBuilder: (context, index) {
          String fullName = filteredCategories[index]['name'];
          String displayName = shortCategoryNames[fullName] ?? fullName;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryListingsPage(
                    category: fullName, // Use full name for backend
                    type: widget.type,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFFD6D6D6),
                    child: Icon(
                      filteredCategories[index]['icon'],
                      color: const Color(0xFF2B2B2B),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 70,
                    child: Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF2B2B2B),
                      ),
                      textAlign: TextAlign.center,
                      // maxLines: 2,
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
