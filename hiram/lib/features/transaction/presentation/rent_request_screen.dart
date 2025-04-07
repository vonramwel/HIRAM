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
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  String? _paymentMethod;
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;
  final TransactionService _transactionService = TransactionService();

  final List<String> _paymentMethods = ['GCash', 'Bank Transfer', 'Cash'];
  String? _transactionId;

  double _totalPrice = 0.0; // Store the total price

  Future<void> _selectDateTime(BuildContext context, bool isStartDate) async {
    DateTime initialDateTime = isStartDate
        ? _startDateTime ?? DateTime.now()
        : _endDateTime ?? (_startDateTime ?? DateTime.now());

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDateTime),
        builder: (context, child) {
          // Limit the picker to the hour only (ignore minutes)
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        // Round the time up to the next hour if it's not on the hour
        int hour = pickedTime.hour;
        if (pickedTime.minute > 0) {
          hour += 1;
        }

        final DateTime fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          hour, // Rounded hour
          0, // Set minute to 0
        );

        setState(() {
          if (isStartDate) {
            // Check if the selected start time is in the past
            if (fullDateTime.isBefore(DateTime.now())) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Start date and time cannot be in the past.'),
                ),
              );
            } else {
              _startDateTime = fullDateTime;

              if (_endDateTime != null &&
                  _startDateTime!.isAfter(_endDateTime!)) {
                _endDateTime = null;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'End date and time has been cleared. Please select a new end datetime.'),
                  ),
                );
              }
            }
          } else {
            if (_startDateTime != null &&
                fullDateTime.isBefore(_startDateTime!)) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Invalid End DateTime'),
                  content: const Text(
                      'End date and time cannot be before start date and time.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            } else {
              _endDateTime = fullDateTime;
            }
          }

          // Recompute the total price whenever start or end time changes
          _computeTotalPrice();
        });
      }
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Select Date & Time';
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Method to compute the total price based on the selected start and end date
  void _computeTotalPrice() {
    if (_startDateTime != null && _endDateTime != null) {
      final duration = _endDateTime!.difference(_startDateTime!);

      if (widget.listing.priceUnit == 'Per Hour') {
        _totalPrice = widget.listing.price * duration.inHours;
      } else if (widget.listing.priceUnit == 'Per Day') {
        _totalPrice =
            widget.listing.price * (duration.inDays == 0 ? 1 : duration.inDays);
      }

      setState(() {});
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate() ||
        _startDateTime == null ||
        _endDateTime == null ||
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

    String? transactionId =
        await _transactionService.getTransactionId(widget.listing.id, userId);

    final transaction = TransactionModel(
      transactionId: transactionId ?? '',
      listingId: widget.listing.id,
      renterId: userId,
      ownerId: widget.listing.userId,
      startDate: _startDateTime!,
      endDate: _endDateTime!,
      paymentMethod: _paymentMethod!,
      notes: _notesController.text,
      status: 'Pending',
      timestamp: Timestamp.now(),
      totalPrice:
          _totalPrice, // Add the computed total price to the transaction
    );

    await _transactionService.addTransaction(transaction);
    setState(() {
      _transactionId = transactionId;
      _isSubmitting = false;
    });

    print("Transaction ID: $_transactionId");
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
                title:
                    Text('Start DateTime: ${_formatDateTime(_startDateTime)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDateTime(context, true),
              ),
              ListTile(
                title: Text('End DateTime: ${_formatDateTime(_endDateTime)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDateTime(context, false),
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
                Text("Transaction ID: $_transactionId"),
              // Display the total price
              Text('Total Price: \Php$_totalPrice'),
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
