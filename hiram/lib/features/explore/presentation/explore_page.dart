import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/service/auth.dart';
import '../../listing/model/listing_model.dart';
import '../../listing/service/listing_service.dart';
import '../../listing/widgets/listing_card.dart';
import '../../../data/philippine_locations.dart'; // Make sure to import your locations map

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final ListingService _listingService = ListingService();
  final Map<String, String> preloadedUserNames = {}; // Cache for user names

  final TextEditingController _searchController =
      TextEditingController(); // Controller for search
  String? selectedType;
  String? selectedCategory;
  String? selectedRegion;
  String? selectedMunicipality;
  String? selectedBarangay;
  String? sortByPriceOrder; // "asc" or "desc"

  final Map<String, List<String>> categoryOptions = {
    'Products for Rent': [
      'Electronics & Gadgets',
      'Vehicles & Transportation',
      'Home & Appliances',
      'Furniture & Decor',
      'Clothing & Accessories',
      'Sports & Outdoor Equipment',
      'Tools & Machinery',
      'Musical Instruments',
      'Books & Learning Materials',
    ],
    'Services for Hire': [
      'Home Services',
      'Event & Party Services',
      'Personal Services',
      'Professional & Technical Services',
      'Vehicle & Transport Services',
    ],
  };

  Future<void> preloadUserNames(List<Listing> listings) async {
    final uniqueUserIds = listings.map((l) => l.userId).toSet();
    for (String userId in uniqueUserIds) {
      if (!preloadedUserNames.containsKey(userId)) {
        final userDoc = await FirebaseFirestore.instance
            .collection('User')
            .doc(userId)
            .get();
        if (userDoc.exists) {
          preloadedUserNames[userId] =
              userDoc.data()?['name'] ?? 'Unknown User';
        } else {
          preloadedUserNames[userId] = 'Unknown User';
        }
      }
    }
    setState(() {});
  }

  void _openFilterModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final categories =
                selectedType != null ? categoryOptions[selectedType]! : [];
            final municipalities = selectedRegion != null
                ? philippineLocations[selectedRegion!]!.keys.toList()
                : [];
            final barangays =
                (selectedRegion != null && selectedMunicipality != null)
                    ? philippineLocations[selectedRegion!]![
                            selectedMunicipality!] ??
                        []
                    : [];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Filter Listings',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Type'),
                      value: selectedType,
                      items: categoryOptions.keys.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedType = value;
                          selectedCategory = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Category'),
                      value: selectedCategory,
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Region'),
                      value: selectedRegion,
                      items: philippineLocations.keys.map((region) {
                        return DropdownMenuItem<String>(
                          value: region,
                          child: Text(region),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedRegion = value;
                          selectedMunicipality = null;
                          selectedBarangay = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Municipality'),
                      value: selectedMunicipality,
                      items: municipalities.map((municipality) {
                        return DropdownMenuItem<String>(
                          value: municipality,
                          child: Text(municipality),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedMunicipality = value;
                          selectedBarangay = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Barangay'),
                      value: selectedBarangay,
                      items: barangays.map((barangay) {
                        return DropdownMenuItem<String>(
                          value: barangay,
                          child: Text(barangay),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedBarangay = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Sort by Price'),
                      value: sortByPriceOrder,
                      items: [
                        const DropdownMenuItem(
                          value: 'asc',
                          child: Text('Lowest to Highest'),
                        ),
                        const DropdownMenuItem(
                          value: 'desc',
                          child: Text('Highest to Lowest'),
                        ),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          sortByPriceOrder = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {});
                      },
                      child: const Text('Apply Filters'),
                    ),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          selectedType = null;
                          selectedCategory = null;
                          selectedRegion = null;
                          selectedMunicipality = null;
                          selectedBarangay = null;
                          sortByPriceOrder = null;
                        });
                      },
                      child: const Text('Clear Filters'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Search Bar with Filter Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search items and services',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {}); // Update the UI when typing
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.grey),
                    onPressed: _openFilterModal,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Listings List
            Expanded(
              child: FutureBuilder<String>(
                future: AuthMethods().getCurrentUserId(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (userSnapshot.hasError ||
                      !userSnapshot.hasData ||
                      userSnapshot.data!.isEmpty) {
                    return const Center(child: Text('Error fetching user.'));
                  }

                  final String currentUserId = userSnapshot.data!;

                  return StreamBuilder<List<Listing>>(
                    stream: _listingService.getListings(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('No listings available.'));
                      }

                      List<Listing> listings = snapshot.data!
                          .where((listing) =>
                              listing.userId != currentUserId &&
                              listing.visibility != 'archived' &&
                              listing.visibility != 'deleted')
                          .toList();

                      // Apply search
                      if (_searchController.text.isNotEmpty) {
                        final query = _searchController.text.toLowerCase();
                        listings = listings
                            .where((listing) =>
                                listing.title.toLowerCase().contains(query))
                            .toList();
                      }

                      // Apply filters
                      if (selectedType != null) {
                        listings = listings
                            .where((listing) => listing.type == selectedType)
                            .toList();
                      }
                      if (selectedCategory != null) {
                        listings = listings
                            .where((listing) =>
                                listing.category == selectedCategory)
                            .toList();
                      }
                      if (selectedRegion != null) {
                        listings = listings
                            .where(
                                (listing) => listing.region == selectedRegion)
                            .toList();
                      }
                      if (selectedMunicipality != null) {
                        listings = listings
                            .where((listing) =>
                                listing.municipality == selectedMunicipality)
                            .toList();
                      }
                      if (selectedBarangay != null) {
                        listings = listings
                            .where((listing) =>
                                listing.barangay == selectedBarangay)
                            .toList();
                      }

                      // Apply price sort
                      if (sortByPriceOrder != null) {
                        listings.sort((a, b) => sortByPriceOrder == 'asc'
                            ? a.price.compareTo(b.price)
                            : b.price.compareTo(a.price));
                      }

                      if (listings.isEmpty) {
                        return const Center(
                            child: Text(
                                'No listings match your search or filters.'));
                      }

                      preloadUserNames(listings);

                      return ListView.builder(
                        itemCount: listings.length,
                        itemBuilder: (context, index) {
                          final listing = listings[index];
                          final userName = preloadedUserNames[listing.userId] ??
                              'Loading...';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ListingCard(
                              listing: listing,
                              userName: userName,
                            ),
                          );
                        },
                      );
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
}
