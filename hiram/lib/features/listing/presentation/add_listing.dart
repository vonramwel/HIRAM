import 'package:flutter/material.dart';
import '../model/listing_model.dart';
import '../service/listing_service.dart';
import '../../auth/service/auth.dart';

class AddListingPage extends StatefulWidget {
  const AddListingPage({super.key});

  @override
  _AddListingPageState createState() => _AddListingPageState();
}

class _AddListingPageState extends State<AddListingPage> {
  final _formKey = GlobalKey<FormState>();
  final ListingService _listingService = ListingService();
  final AuthMethods _authMethods = AuthMethods();

  String _title = '';
  String _description = '';
  String _type = 'Products for Rent'; // Default type
  String? _category; // Category now depends on type
  double _price = 0.0;

  final Map<String, List<String>> _categories = {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Listing')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a title' : null,
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter a description'
                    : null,
                onSaved: (value) => _description = value!,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Type'),
                value: _type,
                items: _categories.keys
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                    _category = null; // Reset category when type changes
                  });
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
                value: _category,
                items: _categories[_type]!
                    .map((category) => DropdownMenuItem(
                        value: category, child: Text(category)))
                    .toList(),
                onChanged: (value) => setState(() => _category = value),
                validator: (value) =>
                    value == null ? 'Select a category' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter a price';
                  final price = double.tryParse(value);
                  return (price == null || price < 0)
                      ? 'Enter a valid price'
                      : null;
                },
                onSaved: (value) => _price = double.parse(value!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Listing'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String userId = await _authMethods.getCurrentUserId();

      final newListing = Listing(
        id: '',
        title: _title,
        description: _description,
        category: _category!,
        type: _type,
        price: _price,
        rating: null,
        userId: userId,
        timestamp: DateTime.now(),
      );

      await _listingService.addListing(newListing);
      Navigator.pop(context);
    }
  }
}
