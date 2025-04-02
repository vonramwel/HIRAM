import 'package:flutter/material.dart';
import '../../listing/model/listing_model.dart';
import '../../auth/service/auth.dart';
import '../model/transaction_model.dart';
import '../service/transaction_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RentRequestScreen extends StatefulWidget {
  final Listing listing;
  const RentRequestScreen({super.key, required this.listing});

  @override
  _RentRequestScreenState createState() => _RentRequestScreenState();
}

class _RentRequestScreenState extends State<RentRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _paymentMethod;
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;
  final TransactionService _transactionService = TransactionService();

  final List<String> _paymentMethods = ['GCash', 'Bank Transfer', 'Cash'];
  String? _transactionId;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate =
        isStartDate ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate() ||
        _startDate == null ||
        _endDate == null ||
        _paymentMethod == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    String? userId = await AuthMethods().getCurrentUserId();
    if (userId == null) {
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    // Fetch the transactionId after adding the transaction
    String? transactionId =
        await _transactionService.getTransactionId(widget.listing.id, userId);

    final transaction = TransactionModel(
      transactionId: transactionId ?? '',
      listingId: widget.listing.id,
      renterId: userId,
      ownerId: widget.listing.userId,
      startDate: _startDate!,
      endDate: _endDate!,
      paymentMethod: _paymentMethod!,
      notes: _notesController.text,
      status: 'Pending',
      timestamp: Timestamp.now(),
    );

    await _transactionService.addTransaction(transaction);
    setState(() {
      _transactionId = transactionId;
      _isSubmitting = false;
    });

    print("Transaction ID: $_transactionId"); // Debugging
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request to Rent')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ListTile(
                title: Text(
                    'Start Date: ${_startDate?.toString().split(' ')[0] ?? 'Select Date'}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              ListTile(
                title: Text(
                    'End Date: ${_endDate?.toString().split(' ')[0] ?? 'Select Date'}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration: const InputDecoration(
                    labelText: 'Preferred Payment Method'),
                items: _paymentMethods.map((method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _paymentMethod = value),
              ),
              TextFormField(
                controller: _notesController,
                decoration:
                    const InputDecoration(labelText: 'Additional Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              if (_transactionId != null)
                Text(
                    "Transaction ID: $_transactionId"), // Display transactionId
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRequest,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Send Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
