// edit_listing_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/listing_model.dart';

class EditListingPage extends StatefulWidget {
  final Listing listing;
  const EditListingPage({super.key, required this.listing});

  @override
  State<EditListingPage> createState() => _EditListingPageState();
}

class _EditListingPageState extends State<EditListingPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController typeController;
  late TextEditingController categoryController;
  late TextEditingController priceController;
  late TextEditingController priceUnitController;
  late TextEditingController transactionMethodController;
  late TextEditingController barangayController;
  late TextEditingController municipalityController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.listing.title);
    descriptionController =
        TextEditingController(text: widget.listing.description);
    typeController = TextEditingController(text: widget.listing.type);
    categoryController = TextEditingController(text: widget.listing.category);
    priceController =
        TextEditingController(text: widget.listing.price.toString());
    priceUnitController = TextEditingController(text: widget.listing.priceUnit);
    transactionMethodController =
        TextEditingController(text: widget.listing.preferredTransaction);
    barangayController = TextEditingController(text: widget.listing.barangay);
    municipalityController =
        TextEditingController(text: widget.listing.municipality);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    typeController.dispose();
    categoryController.dispose();
    priceController.dispose();
    priceUnitController.dispose();
    transactionMethodController.dispose();
    barangayController.dispose();
    municipalityController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('listings')
          .doc(widget.listing.id)
          .update({
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'type': typeController.text.trim(),
        'category': categoryController.text.trim(),
        'price': double.tryParse(priceController.text.trim()) ?? 0.0,
        'priceUnit': priceUnitController.text.trim(),
        'preferredTransaction': transactionMethodController.text.trim(),
        'barangay': barangayController.text.trim(),
        'municipality': municipalityController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing updated successfully!')),
      );

      Navigator.pop(context); // Return to previous page
    }
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          validator: (value) =>
              value == null || value.isEmpty ? 'Required field' : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Listing")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField("Title", titleController),
              _buildTextField("Description", descriptionController),
              _buildTextField("Type", typeController),
              _buildTextField("Category", categoryController),
              _buildTextField("Price", priceController),
              _buildTextField("Price Unit", priceUnitController),
              _buildTextField(
                  "Preferred Transaction", transactionMethodController),
              _buildTextField("Barangay", barangayController),
              _buildTextField("Municipality", municipalityController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
