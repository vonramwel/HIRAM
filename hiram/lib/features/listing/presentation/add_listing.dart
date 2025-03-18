import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../model/listing_model.dart';
import '../service/listing_service.dart';
import '../../auth/service/auth.dart';
import 'dart:io';

class AddListingPage extends StatefulWidget {
  const AddListingPage({super.key});

  @override
  _AddListingPageState createState() => _AddListingPageState();
}

class _AddListingPageState extends State<AddListingPage> {
  final _formKey = GlobalKey<FormState>();
  final ListingService _listingService = ListingService();
  final AuthMethods _authMethods = AuthMethods();
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];

  String _title = '';
  String _description = '';
  String _type = 'Products for Rent';
  String? _category;
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

  Future<void> _pickImages() async {
    if (_images.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only upload up to 5 images.')),
      );
      return;
    }

    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      for (var pickedFile in pickedFiles) {
        final file = File(pickedFile.path);
        if (await file.length() > 5 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Each image must be under 5MB.')),
          );
        } else if (_images.length < 5) {
          setState(() => _images.add(file));
        }
      }
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    for (var image in _images) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref =
          FirebaseStorage.instance.ref().child('listings/$fileName');
      await ref.putFile(image);
      String url = await ref.getDownloadURL();
      imageUrls.add(url);
    }
    return imageUrls;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String userId = await _authMethods.getCurrentUserId();
      List<String> imageUrls = await _uploadImages();

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
        images: imageUrls,
      );

      await _listingService.addListing(newListing);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Listing')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                      _category = null;
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
                  onPressed: _pickImages,
                  child: const Text('Add Images (Up to 5)'),
                ),
                Wrap(
                  spacing: 8,
                  children: _images
                      .map(
                          (image) => Image.file(image, width: 100, height: 100))
                      .toList(),
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
      ),
    );
  }
}
