import 'package:flutter/material.dart';
import '../model/listing_model.dart';
import '../service/listing_service.dart';
import '../../../data/philippine_locations.dart';

class EditListingPage extends StatefulWidget {
  final Listing listing;

  const EditListingPage({Key? key, required this.listing}) : super(key: key);

  @override
  _EditListingPageState createState() => _EditListingPageState();
}

class _EditListingPageState extends State<EditListingPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _otherTransactionController;

  String _type = 'Products for Rent';
  String? _category;
  double _price = 0.0;
  String _priceUnit = 'Per Hour';

  String? _preferredTransaction = 'Pick Up';
  String? _otherTransaction;

  String? _selectedRegion;
  String? _selectedMunicipality;
  String? _selectedBarangay;

  final ListingService _listingService = ListingService();

  final List<String> _transactionOptions = [
    'Pick Up',
    'Delivery',
    'Meet Up',
    'Others',
  ];

  final List<String> _priceUnits = [
    'Per Hour',
    'Per Day',
    'Per Transaction',
  ];

  final List<String> _typeOptions = [
    'Products for Rent',
    'Services for Hire',
  ];

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
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.listing.title);
    _descriptionController =
        TextEditingController(text: widget.listing.description);
    _priceController =
        TextEditingController(text: widget.listing.price.toString());
    _otherTransactionController =
        TextEditingController(text: widget.listing.otherTransaction ?? '');

    _type = widget.listing.type;
    _category = widget.listing.category;
    _priceUnit = widget.listing.priceUnit;
    _preferredTransaction = widget.listing.preferredTransaction;
    _selectedRegion = widget.listing.region;
    _selectedMunicipality = widget.listing.municipality;
    _selectedBarangay = widget.listing.barangay;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _otherTransactionController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      Listing updatedListing = widget.listing.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        type: _type,
        category: _category,
        price: double.tryParse(_priceController.text) ?? 0.0,
        priceUnit: _priceUnit,
        preferredTransaction: _preferredTransaction,
        otherTransaction: _preferredTransaction == 'Others'
            ? _otherTransactionController.text
            : null,
        region: _selectedRegion,
        municipality: _selectedMunicipality,
        barangay: _selectedBarangay,
      );

      await _listingService.updateListing(updatedListing);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> regions = philippineLocations.keys.toList();
    List<String> municipalities = _selectedRegion != null
        ? philippineLocations[_selectedRegion!]!.keys.toList()
        : [];
    List<String> barangays = (_selectedRegion != null &&
            _selectedMunicipality != null)
        ? philippineLocations[_selectedRegion!]![_selectedMunicipality!] ?? []
        : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Listing'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter a title'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _type,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: _typeOptions
                            .map((type) => DropdownMenuItem(
                                value: type, child: Text(type)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _type = value!;
                            _category = null;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Select a type' : null,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _category,
                        decoration:
                            const InputDecoration(labelText: 'Category'),
                        items: (_categories[_type] ?? [])
                            .map((cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)))
                            .toList(),
                        onChanged: (value) => setState(() => _category = value),
                        validator: (value) =>
                            value == null ? 'Select a category' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Price'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter a price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _priceUnit,
                        decoration:
                            const InputDecoration(labelText: 'Price Unit'),
                        items: _priceUnits
                            .map((unit) => DropdownMenuItem(
                                value: unit, child: Text(unit)))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _priceUnit = value!),
                        validator: (value) =>
                            value == null ? 'Select a price unit' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _descriptionController,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        maxLines: 5,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter a description'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _preferredTransaction,
                        decoration: const InputDecoration(
                            labelText: 'Preferred Transaction'),
                        items: _transactionOptions
                            .map((method) => DropdownMenuItem(
                                value: method, child: Text(method)))
                            .toList(),
                        onChanged: (value) => setState(() {
                          _preferredTransaction = value;
                          if (value != 'Others') {
                            _otherTransactionController.clear();
                          }
                        }),
                        validator: (value) => value == null
                            ? 'Select a transaction method'
                            : null,
                      ),
                      if (_preferredTransaction == 'Others') ...[
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _otherTransactionController,
                          decoration: const InputDecoration(
                              labelText: 'Other Transaction Details'),
                          validator: (value) {
                            if (_preferredTransaction == 'Others' &&
                                (value == null || value.isEmpty)) {
                              return 'Enter transaction details';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedRegion,
                        decoration: const InputDecoration(labelText: 'Region'),
                        items: regions
                            .map((region) => DropdownMenuItem(
                                value: region, child: Text(region)))
                            .toList(),
                        onChanged: (value) => setState(() {
                          _selectedRegion = value;
                          _selectedMunicipality = null;
                          _selectedBarangay = null;
                        }),
                        validator: (value) =>
                            value == null ? 'Select a region' : null,
                      ),
                      const SizedBox(height: 10),
                      if (_selectedRegion != null)
                        DropdownButtonFormField<String>(
                          value: _selectedMunicipality,
                          decoration:
                              const InputDecoration(labelText: 'Municipality'),
                          items: municipalities
                              .map((municipality) => DropdownMenuItem(
                                  value: municipality,
                                  child: Text(municipality)))
                              .toList(),
                          onChanged: (value) => setState(() {
                            _selectedMunicipality = value;
                            _selectedBarangay = null;
                          }),
                          validator: (value) =>
                              value == null ? 'Select a municipality' : null,
                        ),
                      const SizedBox(height: 10),
                      if (_selectedMunicipality != null)
                        DropdownButtonFormField<String>(
                          value: _selectedBarangay,
                          decoration:
                              const InputDecoration(labelText: 'Barangay'),
                          items: barangays
                              .map((barangay) => DropdownMenuItem(
                                  value: barangay, child: Text(barangay)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedBarangay = value),
                          validator: (value) =>
                              value == null ? 'Select a barangay' : null,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
