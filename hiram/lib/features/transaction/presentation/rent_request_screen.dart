import 'package:flutter/material.dart';
import '../../listing/model/listing_model.dart';
import '../../auth/service/auth.dart';
import '../model/transaction_model.dart';
import '../service/transaction_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/service/database.dart';
import '../../../common_widgets/common_widgets.dart'; // Importing the custom widgets
import '../../inbox/presentation/chat_page.dart'; // Importing ChatPage for contact feature
import '../../../common_widgets/booked_schedule.dart';

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
  final TextEditingController _offeredPriceController = TextEditingController();
  bool _isSubmitting = false;
  final TransactionService _transactionService = TransactionService();
  final DatabaseMethods _databaseMethods = DatabaseMethods();

  final List<String> _paymentMethods = ['GCash', 'Bank Transfer', 'Cash'];
  String? _transactionId;
  double _totalPrice = 0.0;
  String _postedBy = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      Map<String, dynamic>? userData =
          await _databaseMethods.getUserData(widget.listing.userId);
      if (userData != null && mounted) {
        setState(() {
          _postedBy = userData['name'] ?? 'Unknown User';
        });
      } else {
        setState(() {
          _postedBy = 'Unknown User';
        });
      }
    } catch (e) {
      setState(() {
        _postedBy = 'Error loading user';
      });
    }
  }

  Future<void> _selectDateTime(BuildContext context, bool isStartDate) async {
    DateTime initialDateTime = isStartDate
        ? _startDateTime ?? DateTime.now()
        : _endDateTime ?? (_startDateTime ?? DateTime.now());

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate:
          isStartDate ? DateTime.now() : (_startDateTime ?? DateTime.now()),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDateTime),
      );

      if (pickedTime != null) {
        int hour = pickedTime.hour;
        if (pickedTime.minute > 0) hour++;
        final DateTime fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          hour,
        );

// Compute proposed range
        final proposedStart = isStartDate ? fullDateTime : _startDateTime;
        final proposedEnd = isStartDate ? _endDateTime : fullDateTime;

// Check for overlap

        setState(() {
          if (isStartDate) {
            if (fullDateTime.isBefore(DateTime.now())) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Start date and time cannot be in the past.')),
              );
            } else {
              _startDateTime = fullDateTime;
              if (_endDateTime != null &&
                  _startDateTime!.isAfter(_endDateTime!)) {
                _endDateTime = null;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'End date cleared. Please select a new end datetime.')),
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
                        child: const Text('OK'))
                  ],
                ),
              );
            } else {
              _endDateTime = fullDateTime;
            }
          }
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

  void _computeTotalPrice() {
    if (_startDateTime != null && _endDateTime != null) {
      final duration = _endDateTime!.difference(_startDateTime!);
      _totalPrice = widget.listing.price *
          (widget.listing.priceUnit == 'Per Hour'
              ? duration.inHours
              : (duration.inDays == 0 ? 1 : duration.inDays));
      setState(() {});
    }
  }

  double _getFinalTotalPrice() {
    if (_offeredPriceController.text.isNotEmpty) {
      double? offered = double.tryParse(_offeredPriceController.text);
      if (offered != null && offered >= 0) {
        return offered;
      }
    }
    return _totalPrice;
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate() ||
        _startDateTime == null ||
        _endDateTime == null ||
        _paymentMethod == null) return;

    setState(() => _isSubmitting = true);

    String? userId = await AuthMethods().getCurrentUserId();
    if (userId == null) {
      setState(() => _isSubmitting = false);
      return;
    }

    // ✅ Check for booking conflicts in listing.bookedSchedules
    final booked = widget.listing.bookedSchedules ?? [];

    bool hasConflict = booked.any((schedule) {
      final bookedStart = DateTime.tryParse(schedule['startDate'] ?? '');
      final bookedEnd = DateTime.tryParse(schedule['endDate'] ?? '');
      if (bookedStart == null || bookedEnd == null) return false;

      return !(_endDateTime!.isBefore(bookedStart) ||
          _startDateTime!.isAfter(bookedEnd));
    });

    if (hasConflict) {
      setState(() => _isSubmitting = false);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Date Unavailable'),
          content: const Text(
              'The selected time range overlaps with an existing booking.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
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
      totalPrice: _totalPrice,
      offeredPrice: _offeredPriceController.text.isNotEmpty
          ? double.tryParse(_offeredPriceController.text)
          : null,
    );

    await _transactionService.addTransaction(transaction);

    setState(() {
      _transactionId = transactionId;
      _isSubmitting = false;
    });

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _notesController.dispose();
    _offeredPriceController.dispose();
    super.dispose();
  }

  void _contactSeller() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          receiverId: widget.listing.userId,
          receiverName: _postedBy,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rent'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: _contactSeller,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 39, 39, 39),
                foregroundColor: Colors.white,
              ),
              child: const Text("Contact Seller"),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageCarousel(imageUrls: widget.listing.images),
              const SizedBox(height: 10),
              Text('Posted by: $_postedBy',
                  style: const TextStyle(fontStyle: FontStyle.italic)),
              const SizedBox(height: 10),
              CustomTextField(label: 'Listing', value: widget.listing.title),
              const SizedBox(height: 10),
              CustomTwoFields(
                label1: 'Price',
                value1: '₱${widget.listing.price.toStringAsFixed(2)}',
                label2: 'Unit',
                value2: widget.listing.priceUnit,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                  label: 'Preferred Transaction',
                  value:
                      widget.listing.preferredTransaction ?? 'Not specified'),
              const SizedBox(height: 10),
              CustomTextField(
                  label: 'Location',
                  value:
                      '${widget.listing.barangay ?? ''}, ${widget.listing.municipality ?? ''}'),
              const SizedBox(height: 10),
              ListTile(
                title: Text('Start: ${_formatDateTime(_startDateTime)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDateTime(context, true),
              ),
              ListTile(
                title: Text('End: ${_formatDateTime(_endDateTime)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDateTime(context, false),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => BookedScheduleDialog(
                      bookedSchedules: widget.listing.bookedSchedules ?? [],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color.fromARGB(255, 39, 39, 39),
                  foregroundColor: Colors.white,
                ),
                child: const Text('View Schedule'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration: const InputDecoration(labelText: 'Payment Method'),
                items: _paymentMethods
                    .map((method) => DropdownMenuItem<String>(
                        value: method, child: Text(method)))
                    .toList(),
                onChanged: (value) => setState(() => _paymentMethod = value),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Text('Total Price: ₱${_getFinalTotalPrice().toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _offeredPriceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Offered Price (optional)',
                  hintText: 'Enter offered price if different',
                ),
              ),
              const SizedBox(height: 10),
              if (_transactionId != null)
                Text("Transaction ID: $_transactionId",
                    style: const TextStyle(
                        fontSize: 12, fontStyle: FontStyle.italic)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color.fromARGB(255, 39, 39, 39),
                  foregroundColor: Colors.white,
                ),
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
