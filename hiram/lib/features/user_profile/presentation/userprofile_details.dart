import 'package:flutter/material.dart';
import '../../auth/service/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../transaction/presentation/common_widgets.dart';
import '../../../data/philippine_locations.dart';

class UserProfileDetails extends StatefulWidget {
  const UserProfileDetails({super.key});

  @override
  State<UserProfileDetails> createState() => _UserProfileDetailsState();
}

class _UserProfileDetailsState extends State<UserProfileDetails> {
  final DatabaseMethods _databaseMethods = DatabaseMethods();

  String _name = '';
  String _email = '';
  String _phone = '';
  String _address = '';
  String _bio = '';

  String? _selectedRegion;
  String? _selectedMunicipality;
  String? _selectedBarangay;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    Map<String, dynamic>? userData =
        await _databaseMethods.getCurrentUserData();
    if (userData != null && mounted) {
      _address = userData['address'] ?? '';
      List<String> addressParts = _address.split(', ').reversed.toList();
      setState(() {
        _name = userData['name'] ?? 'Unknown';
        _email = user?.email ?? '';
        _phone = userData['contactNumber'] ?? '';
        _bio = userData['bio'] ?? '';

        _phoneController.text = _phone;
        _bioController.text = _bio;

        // Attempt to split address into components if possible
        if (addressParts.length == 3) {
          _selectedRegion = addressParts[2];
          _selectedMunicipality = addressParts[1];
          _selectedBarangay = addressParts[0];
        }
      });
    }
  }

  Future<void> _saveProfileChanges() async {
    final combinedAddress = (_selectedBarangay != null &&
            _selectedMunicipality != null &&
            _selectedRegion != null)
        ? '$_selectedBarangay, $_selectedMunicipality, $_selectedRegion'
        : _address;

    await _databaseMethods.updateCurrentUserData({
      'contactNumber': _phoneController.text,
      'address': combinedAddress,
      'bio': _bioController.text,
    });

    Navigator.pop(context);
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            CustomTextField(label: 'Name', value: _name),
            const SizedBox(height: 12),
            CustomTextField(label: 'Email', value: _email),
            const SizedBox(height: 20),
            const Text(
              'Edit Contact Info',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              decoration: _fieldDecoration('Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: _fieldDecoration('Region'),
              value: _selectedRegion,
              items: philippineLocations.keys
                  .map((region) =>
                      DropdownMenuItem(value: region, child: Text(region)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRegion = value;
                  _selectedMunicipality = null;
                  _selectedBarangay = null;
                });
              },
              validator: (value) => value == null ? 'Select a region' : null,
            ),
            const SizedBox(height: 10),
            if (_selectedRegion != null)
              DropdownButtonFormField<String>(
                decoration: _fieldDecoration('Municipality'),
                value: _selectedMunicipality,
                items: philippineLocations[_selectedRegion]!
                    .keys
                    .map((municipality) => DropdownMenuItem(
                        value: municipality, child: Text(municipality)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMunicipality = value;
                    _selectedBarangay = null;
                  });
                },
              ),
            const SizedBox(height: 10),
            if (_selectedMunicipality != null)
              DropdownButtonFormField<String>(
                decoration: _fieldDecoration('Barangay'),
                value: _selectedBarangay,
                items: philippineLocations[_selectedRegion]![
                        _selectedMunicipality]!
                    .map((barangay) => DropdownMenuItem(
                        value: barangay, child: Text(barangay)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedBarangay = value),
              ),
            const SizedBox(height: 10),
            TextField(
              controller: _bioController,
              decoration: _fieldDecoration('Bio'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            CustomButton(label: 'Save Changes', onPressed: _saveProfileChanges),
          ],
        ),
      ),
    );
  }
}
