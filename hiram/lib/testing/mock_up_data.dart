import 'dart:math';
import 'package:uuid/uuid.dart';
import '../../features/listing/model/listing_model.dart';
import '../../features/listing/service/listing_service.dart';

class MockListingGenerator {
  final ListingService _listingService = ListingService();
  final Random _random = Random();
  final Uuid _uuid = Uuid();

  final List<String> userIds = [
    '32BAPdGNbNdbcAL4TYJAMkqGAex2',
    'FYUEYAr5JVabPf6yVSQuqQcOMgs2',
  ];

  final Map<String, List<String>> typeToCategories = {
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

  final Map<String, Map<String, List<String>>> locations = {
    'Region IV-A (CALABARZON)': {
      'Laguna': ['Los Baños', 'Calamba', 'Santa Rosa'],
      'Batangas': ['Batangas City', 'Lipa', 'Tanauan'],
    },
    'NCR': {
      'Quezon City': ['Batasan Hills', 'Commonwealth', 'Fairview'],
      'Manila': ['Ermita', 'Malate', 'Tondo'],
    },
  };

  final Map<String, List<Map<String, String>>> sampleData = {
    'Electronics & Gadgets': [
      {
        'title': 'Cherry Mobile Flare S8 Plus',
        'description':
            'Affordable dual-SIM Android phone ideal for events, travel, or temporary use. Comes with charger and case.'
      },
      {
        'title': 'WiFi Pocket Router (Globe at Home LTE)',
        'description':
            'Reliable LTE signal for online classes or work-from-home setups. Load not included.'
      },
    ],
    'Home & Appliances': [
      {
        'title': 'Kalan with LPG Tank (2-burner)',
        'description':
            'Heavy-duty stove with full LPG tank—ideal for events or backup cooking needs.'
      },
      {
        'title': 'Stand Fan (Industrial Type)',
        'description':
            'Powerful electric fan for parties, catering, or sari-sari store use.'
      },
    ],
    'Furniture & Decor': [
      {
        'title': 'Foldable Banquet Tables',
        'description':
            'Plastic tables good for 6 people. Ideal for fiestas, meetings, or events.'
      },
      {
        'title': 'Curtains and Dividers for Rent',
        'description':
            'Perfect for decorating venues like barangay halls or open-air events.'
      },
    ],
    'Clothing & Accessories': [
      {
        'title': 'Filipiniana Dress - Medium',
        'description':
            'Elegant modern Filipiniana for Buwan ng Wika, cultural contests, or themed events.'
      },
      {
        'title': 'Barong Tagalog (Large)',
        'description':
            'Classic embroidered Barong for formal events. Dry-cleaned and ready to wear.'
      },
    ],
    'Sports & Outdoor Equipment': [
      {
        'title': 'Basketball and Net Set',
        'description':
            'Standard ball with portable ring for barangay tournaments or weekend games.'
      },
      {
        'title': 'Camping Tent (4-person)',
        'description':
            'Perfect for beach camping, school field trips, or overnight hikes.'
      },
    ],
    'Tools & Machinery': [
      {
        'title': 'Grass Cutter (Gasoline-Powered)',
        'description':
            'For backyard cleaning, lot maintenance, and community clean-up drives.'
      },
      {
        'title': 'Electric Drill Set',
        'description':
            'Includes drill bits and extension cord. Ideal for minor home repairs.'
      },
    ],
    'Musical Instruments': [
      {
        'title': 'Acoustic Guitar (Yamaha)',
        'description':
            'Well-maintained 6-string guitar for gigs, mass services, or music classes.'
      },
      {
        'title': 'Electric Keyboard (61 Keys)',
        'description':
            'Perfect for school performances, band rehearsals, or events.'
      },
    ],
    'Books & Learning Materials': [
      {
        'title': 'Senior High STEM Review Books',
        'description':
            'Complete reviewer bundle for entrance exams like UPCAT and DOST-SEI.'
      },
      {
        'title': 'Elementary Reading Sets',
        'description':
            'Includes Filipino and English storybooks suitable for Grades 1–3 learners.'
      },
    ],
    'Personal Services': [
      {
        'title': 'Haircut at Home - Barangay Service',
        'description':
            'Home service haircut available for kids, adults, and seniors.'
      },
      {
        'title': 'Makeup for Debut/Birthday',
        'description':
            'Professional makeup for special events. Barangay/home service available.'
      },
    ],
    'Vehicle & Transport Services': [
      {
        'title': 'Motorcycle Delivery Service',
        'description':
            'Barangay to barangay courier for small items and food orders.'
      },
      {
        'title': 'UV Express Rent for Barkada Outing',
        'description':
            'Good for 10 pax, with driver and fuel options. Ideal for beach trips.'
      },
    ],
  };

  final Map<String, List<String>> sampleImages = {
    'Electronics & Gadgets': [
      'https://example.com/images/camera.jpg',
      'https://example.com/images/laptop.jpg',
    ],
    'Vehicles & Transportation': [
      'https://example.com/images/vios.jpg',
      'https://example.com/images/bike.jpg',
    ],
    'Home & Appliances': [
      'https://example.com/images/fridge.jpg',
    ],
    'Event & Party Services': [
      'https://example.com/images/host.jpg',
    ],
    'Clothing & Accessories': [
      'https://example.com/images/gown.jpg',
    ],
  };

  Future<void> generateMockListings({int count = 10}) async {
    for (int i = 0; i < count; i++) {
      final String type = _randomType();
      final String category = _randomCategory(type);
      final String region = _randomRegion();
      final String municipality = _randomMunicipality(region);
      final String barangay = _randomBarangay(region, municipality);

      final listingData = _randomSampleData(category);
      final images = _randomImages(category);

      final Listing listing = Listing(
        id: '',
        title: listingData['title']!,
        description: listingData['description']!,
        category: category,
        type: type,
        rating: null,
        ratingCount: null,
        price: (_random.nextInt(90) + 10).toDouble(),
        priceUnit: 'Per Day',
        userId: userIds[_random.nextInt(userIds.length)],
        timestamp: DateTime.now(),
        images: images,
        preferredTransaction: [
          'Pick Up',
          'Delivery',
          'Meet Up',
          'Others'
        ][_random.nextInt(4)],
        otherTransaction: 'Please contact me for more details.',
        region: region,
        municipality: municipality,
        barangay: barangay,
        visibility: 'visible',
      );

      await _listingService.addListing(listing);
    }
  }

  String _randomType() {
    return typeToCategories.keys
        .elementAt(_random.nextInt(typeToCategories.length));
  }

  String _randomCategory(String type) {
    return typeToCategories[type]![
        _random.nextInt(typeToCategories[type]!.length)];
  }

  String _randomRegion() {
    final regions = locations.keys.toList();
    return regions[_random.nextInt(regions.length)];
  }

  String _randomMunicipality(String region) {
    final municipalities = locations[region]!.keys.toList();
    return municipalities[_random.nextInt(municipalities.length)];
  }

  String _randomBarangay(String region, String municipality) {
    final barangays = locations[region]![municipality]!;
    return barangays[_random.nextInt(barangays.length)];
  }

  Map<String, String> _randomSampleData(String category) {
    if (sampleData.containsKey(category)) {
      final items = sampleData[category]!;
      return items[_random.nextInt(items.length)];
    }
    return {
      'title': '$category Item',
      'description':
          'High-quality $category item available for rent. Contact for details.',
    };
  }

  List<String> _randomImages(String category) {
    if (sampleImages.containsKey(category)) {
      return [
        sampleImages[category]![_random.nextInt(sampleImages[category]!.length)]
      ];
    }
    return [];
  }
}
