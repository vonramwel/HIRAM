import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../model/listing_model.dart';
import '../service/listing_service.dart';
import '../../auth/service/auth.dart';
import '../../../data/philippine_locations.dart';
import '../../../common_widgets/common_widgets.dart';
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
  String _priceUnit = 'Per Hour';
  String? _preferredTransaction = 'Pick Up';
  String? _otherTransaction;
  String? _selectedRegion;
  String? _selectedMunicipality;
  String? _selectedBarangay;

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
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      for (var pickedFile in pickedFiles) {
        final file = File(pickedFile.path);
        if (!file.existsSync()) continue;

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

      final preferredTransactionValue = _preferredTransaction == 'Others'
          ? _otherTransaction
          : _preferredTransaction;

      final newListing = Listing(
        id: '',
        title: _title,
        description: _description,
        category: _category!,
        type: _type,
        price: _price,
        priceUnit: _priceUnit,
        rating: null,
        userId: userId,
        timestamp: DateTime.now(),
        images: imageUrls,
        preferredTransaction: preferredTransactionValue,
        region: _selectedRegion,
        municipality: _selectedMunicipality,
        barangay: _selectedBarangay,
      );

      await _listingService.addListing(newListing);
      if (mounted) Navigator.pop(context);
    }
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: pepperBlack),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;

        return Scaffold(
          appBar: AppBar(title: const Text('Post a New Listing')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: maxWidth < 600 ? double.infinity : 600),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        decoration: _fieldDecoration('Title'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter a title'
                            : null,
                        onSaved: (value) => _title = value!,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: _fieldDecoration('Description'),
                        maxLines: 3,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter a description'
                            : null,
                        onSaved: (value) => _description = value!,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _type == 'Products for Rent'
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.shade300,
                                foregroundColor: _type == 'Products for Rent'
                                    ? Colors.white
                                    : Colors.black,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () =>
                                  setState(() => _type = 'Products for Rent'),
                              child: const Text('Product'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _type == 'Services for Hire'
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.shade300,
                                foregroundColor: _type == 'Services for Hire'
                                    ? Colors.white
                                    : Colors.black,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () =>
                                  setState(() => _type = 'Services for Hire'),
                              child: const Text('Service'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: _fieldDecoration('Category'),
                        value: _category,
                        items: _categories[_type]!
                            .map((category) => DropdownMenuItem(
                                value: category, child: Text(category)))
                            .toList(),
                        onChanged: (value) => setState(() => _category = value),
                        validator: (value) =>
                            value == null ? 'Select a category' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Flexible(
                            flex: 2,
                            child: TextFormField(
                              decoration: _fieldDecoration('Price'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter a price';
                                }
                                final price = double.tryParse(value);
                                return (price == null || price < 0)
                                    ? 'Enter a valid price'
                                    : null;
                              },
                              onSaved: (value) => _price = double.parse(value!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            flex: 3,
                            child: DropdownButtonFormField<String>(
                              decoration: _fieldDecoration('Price Unit'),
                              value: _priceUnit,
                              items: ['Per Hour', 'Per Day', 'Per Transaction']
                                  .map((unit) => DropdownMenuItem(
                                      value: unit, child: Text(unit)))
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _priceUnit = value!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration:
                            _fieldDecoration('Preferred Means of Transaction'),
                        value: _preferredTransaction,
                        items: ['Pick Up', 'Delivery', 'Meet Up', 'Others']
                            .map((option) => DropdownMenuItem(
                                value: option, child: Text(option)))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _preferredTransaction = value),
                      ),
                      const SizedBox(height: 12),
                      if (_preferredTransaction == 'Others')
                        TextFormField(
                          decoration: _fieldDecoration(
                              'Specify Other Means of Transaction'),
                          validator: (value) {
                            if (_preferredTransaction == 'Others' &&
                                (value == null || value.isEmpty)) {
                              return 'Please specify your transaction method';
                            }
                            return null;
                          },
                          onSaved: (value) => _otherTransaction = value,
                        ),
                      DropdownButtonFormField<String>(
                        decoration: _fieldDecoration('Region'),
                        value: _selectedRegion,
                        items: philippineLocations.keys
                            .map((region) => DropdownMenuItem(
                                value: region, child: Text(region)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRegion = value;
                            _selectedMunicipality = null;
                            _selectedBarangay = null;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Select a region' : null,
                      ),
                      const SizedBox(height: 12),
                      if (_selectedRegion != null)
                        DropdownButtonFormField<String>(
                          decoration: _fieldDecoration('Municipality'),
                          value: _selectedMunicipality,
                          items: philippineLocations[_selectedRegion]!
                              .keys
                              .map((municipality) => DropdownMenuItem(
                                  value: municipality,
                                  child: Text(municipality)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedMunicipality = value;
                              _selectedBarangay = null;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Select a municipality' : null,
                        ),
                      const SizedBox(height: 12),
                      if (_selectedMunicipality != null)
                        DropdownButtonFormField<String>(
                          decoration: _fieldDecoration('Barangay'),
                          value: _selectedBarangay,
                          items: philippineLocations[_selectedRegion]![
                                  _selectedMunicipality]!
                              .map((barangay) => DropdownMenuItem(
                                  value: barangay, child: Text(barangay)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedBarangay = value),
                          validator: (value) =>
                              value == null ? 'Select a barangay' : null,
                        ),
                      const SizedBox(height: 16),
                      CustomButton(
                        label: 'Add Images (up to 5)',
                        onPressed: _pickImages,
                      ),
                      const SizedBox(height: 12),
                      if (_images.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _images
                              .map((image) => ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(image,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover),
                                  ))
                              .toList(),
                        ),
                      const SizedBox(height: 20),
                      CustomButton(
                        label: 'SUBMIT',
                        onPressed: _submitForm,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
