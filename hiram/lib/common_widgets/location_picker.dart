import 'package:flutter/material.dart';

class LocationPicker extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const LocationPicker({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: items
          .map((item) =>
              DropdownMenuItem<String>(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
