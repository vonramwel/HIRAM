import 'package:flutter/material.dart';
import '../service/transaction_service.dart';
import '../model/transaction_model.dart';
import '../../auth/service/auth.dart';
import '../../auth/service/database.dart';
import '../../review/presentation/review_screen.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../common_widgets/common_widgets.dart';
import 'generated_code_dialog.dart';
import 'input_code_dialog.dart';
import '../../review/presentation/user_reviews_page.dart';
import '../../report/presentation/report_transaction.dart';
import '../../../common_widgets/booked_schedule.dart';

class TransactionDetails extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionDetails({super.key, required this.transaction});

  @override
  _TransactionDetailsState createState() => _TransactionDetailsState();
}

class _TransactionDetailsState extends State<TransactionDetails> {
  String? _userId;
  String? _generatedCode;
  String _otherUserName = 'Loading...';
  String _otherUserLabel = 'User';
  final TransactionService _transactionService = TransactionService();
  final AuthMethods _authMethods = AuthMethods();
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  bool _hasShownReviewDialog = false;
  List<String> _listingImages = [];
  bool _isOtherUserLocked = false;
  List<Map<String, String>> bookedSchedules = [];

  @override
  void initState() {
    super.initState();
    _fetchUserId();
    _fetchListingImages();
    _fetchBookedSchedules();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.transaction.status == "Completed") {
        _navigateToReviewIfNeeded();
      }
    });
  }

  Future<void> _fetchUserId() async {
    String? userId = await _authMethods.getCurrentUserId();
    setState(() {
      _userId = userId;
    });
    _fetchOtherUserName(userId);
  }

  Future<void> _fetchBookedSchedules() async {
    try {
      final listingDoc = await FirebaseFirestore.instance
          .collection('listings')
          .doc(widget.transaction.listingId)
          .get();

      if (listingDoc.exists) {
        List<dynamic> schedules = listingDoc.data()?['bookedSchedules'] ?? [];

        setState(() {
          bookedSchedules = schedules
              .map<Map<String, String>>(
                  (item) => Map<String, String>.from(item))
              .toList();
        });
      }
    } catch (e) {
      print('Error fetching booked schedules: $e');
    }
  }

  bool _isOverlapping(
      DateTime newStart, DateTime newEnd, List<dynamic> bookedSchedules) {
    for (var schedule in bookedSchedules) {
      final DateTime existingStart = DateTime.parse(schedule['startDate']);
      final DateTime existingEnd = DateTime.parse(schedule['endDate']);

      // Check if ranges overlap
      if (newStart.isBefore(existingEnd) && newEnd.isAfter(existingStart)) {
        return true;
      }
    }
    return false;
  }

  Future<void> _fetchOtherUserName(String? currentUserId) async {
    if (currentUserId == null) return;

    String otherUserId = currentUserId == widget.transaction.ownerId
        ? widget.transaction.renterId
        : widget.transaction.ownerId;

    setState(() {
      _otherUserLabel =
          currentUserId == widget.transaction.ownerId ? 'Renter' : 'Owner';
    });

    try {
      Map<String, dynamic>? userData =
          await _databaseMethods.getUserData(otherUserId);
      setState(() {
        _otherUserName = userData?['name'] ?? 'Unknown User';
        String? status = userData?['accountStatus'];
        _isOtherUserLocked = status == 'locked' || status == 'banned';
      });
    } catch (e) {
      setState(() {
        _otherUserName = 'Error loading user';
        _isOtherUserLocked = false;
      });
    }
  }

  Future<void> _fetchListingImages() async {
    try {
      DocumentSnapshot listingSnapshot = await FirebaseFirestore.instance
          .collection('listings')
          .doc(widget.transaction.listingId)
          .get();

      if (listingSnapshot.exists) {
        List<dynamic> images = listingSnapshot.get('images') ?? [];
        setState(() {
          _listingImages = List<String>.from(images);
        });
      }
    } catch (e) {
      print('Error fetching listing images: $e');
    }
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('MM-dd-yyyy hh:mm a').format(dateTime.toLocal());
  }

  void _generateTransactionCode() async {
    String code = await _transactionService
        .generateTransactionCode(widget.transaction.transactionId);
    setState(() {
      _generatedCode = code;
    });
    Navigator.pop(context);

    GenerateCodeDialog.show(context, code);
  }

  void _showInputDialog() {
    InputCodeDialog.show(
      context: context,
      transactionId: widget.transaction.transactionId,
      status: widget.transaction.status,
      updateStatusCallback: _updateTransactionStatus,
    );
  }

  Future<void> _updateTransactionStatus(String newStatus) async {
    if (newStatus == 'Approved') {
      final listingDoc = await FirebaseFirestore.instance
          .collection('listings')
          .doc(widget.transaction.listingId)
          .get();

      bookedSchedules = (listingDoc.data()?['bookedSchedules'] ?? [])
          .map<Map<String, String>>((item) => Map<String, String>.from(item))
          .toList();

      if (_isOverlapping(widget.transaction.startDate,
          widget.transaction.endDate, bookedSchedules)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('This schedule overlaps with an existing booking.')),
        );
        return; // prevent further approval
      }
      if (widget.transaction.offeredPrice != null) {
        await _transactionService.updateTransactionStatusAndTotalPrice(
          widget.transaction.transactionId,
          widget.transaction.listingId,
          widget.transaction.renterId,
          newStatus,
          widget.transaction.offeredPrice!,
        );
        setState(() {
          widget.transaction.totalPrice = widget.transaction.offeredPrice!;
        });
      } else {
        await _transactionService.updateTransactionStatusOnly(
          widget.transaction.transactionId,
          widget.transaction.listingId,
          widget.transaction.renterId,
          newStatus,
        );
      }

      // ⬇️ Add booking schedule to listing document
      await FirebaseFirestore.instance
          .collection('listings')
          .doc(widget.transaction.listingId)
          .update({
        'bookedSchedules': FieldValue.arrayUnion([
          {
            'startDate': widget.transaction.startDate.toIso8601String(),
            'endDate': widget.transaction.endDate.toIso8601String(),
          }
        ])
      });

      setState(() {
        widget.transaction.status = newStatus;
      });
    } else {
      await _transactionService.updateTransactionStatus(
        widget.transaction.transactionId,
        widget.transaction.listingId,
        widget.transaction.renterId,
        newStatus,
      );
      setState(() {
        widget.transaction.status = newStatus;
      });
    }

    if (newStatus == 'Completed') {
      _navigateToReviewIfNeeded();
    }
  }

  void _navigateToReviewIfNeeded() {
    if (!_hasShownReviewDialog &&
        widget.transaction.status == "Completed" &&
        ((_userId == widget.transaction.renterId &&
                !widget.transaction.hasReviewedByRenter) ||
            (_userId == widget.transaction.ownerId &&
                !widget.transaction.hasReviewedByLender))) {
      _hasShownReviewDialog = true;

      Future.delayed(Duration.zero, () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewScreen(
              transaction: widget.transaction,
            ),
          ),
        );
      });
    }
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => ReportTransactionDialog(
        transactionId: widget.transaction.transactionId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isOwner = _userId == widget.transaction.ownerId;
    bool isRenter = _userId == widget.transaction.renterId;
    bool isApproved = widget.transaction.status == "Approved";
    bool isLent = widget.transaction.status == "Lent";
    bool isCompleted = widget.transaction.status == "Completed";
    bool isStartDateToday =
        widget.transaction.startDate.toLocal().day == DateTime.now().day;
    bool isEndDateToday =
        widget.transaction.endDate.toLocal().day == DateTime.now().day;

    bool shouldShowReviewButton = isCompleted &&
        ((_userId == widget.transaction.renterId &&
                !widget.transaction.hasReviewedByRenter) ||
            (_userId == widget.transaction.ownerId &&
                !widget.transaction.hasReviewedByLender));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction Details"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'report') {
                _showReportDialog();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'report',
                  child: Text('Report Transaction'),
                ),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImageCarousel(imageUrls: _listingImages),
            const SizedBox(height: 20),
            CustomTextField(
                label: "$_otherUserLabel Name", value: _otherUserName),
            if (_isOtherUserLocked) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.warning, size: 16, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(
                    _isOtherUserLocked && _otherUserName.contains('banned')
                        ? "This account is banned"
                        : "This account is locked",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            if (isOwner && _userId != null) ...[
              const SizedBox(height: 10),
              CustomButton(
                label: "View Renter Reviews",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RenterReviewDetailsPage(
                        renterId: widget.transaction.renterId,
                        ownerId: widget.transaction.ownerId,
                      ),
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 10),
            CustomTextField(
                label: "Payment Method",
                value: widget.transaction.paymentMethod),
            const SizedBox(height: 10),
            CustomTwoFields(
              label1: "Start Date",
              value1: formatDateTime(widget.transaction.startDate),
              label2: "End Date",
              value2: formatDateTime(widget.transaction.endDate),
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => BookedScheduleDialog(
                    bookedSchedules: bookedSchedules ?? [],
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
            if (widget.transaction.offeredPrice != null) ...[
              CustomTextField(
                label: "Offered Price",
                value: widget.transaction.offeredPrice.toString(),
              ),
              const SizedBox(height: 10),
            ],
            CustomTextField(label: "Notes", value: widget.transaction.notes),
            const SizedBox(height: 10),
            CustomTextField(label: "Status", value: widget.transaction.status),
            const SizedBox(height: 20),
            // Handle button row styles based on conditions
            if (isOwner && isApproved && isStartDateToday) ...[
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.6, // Adjust this to 0.5 for 50% width
                  child: CustomButton(
                    label: "Generate Transaction Code",
                    onPressed: _generateTransactionCode,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (_generatedCode != null)
                Center(child: Text("Generated Code: $_generatedCode")),
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.6,
                  child: CustomButton(
                    label: "Cancel Transaction",
                    onPressed: () => _updateTransactionStatus("Cancelled"),
                  ),
                ),
              ),
            ],
            if (isRenter && isApproved && isStartDateToday) ...[
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.4,
                  child: CustomButton(
                    label: "Input Code",
                    onPressed: _showInputDialog,
                  ),
                ),
              ),
            ],
            if (isOwner && !isApproved && !isLent && !isCompleted) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: FractionallySizedBox(
                      widthFactor: 0.4,
                      child: CustomButton(
                        label: "Accept",
                        onPressed: () => _updateTransactionStatus("Approved"),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FractionallySizedBox(
                      widthFactor: 0.4,
                      child: CustomButton(
                        label: "Decline",
                        onPressed: () =>
                            _updateTransactionStatus("Disapproved"),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (isRenter && !isApproved && !isLent && !isCompleted) ...[
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.4,
                  child: CustomButton(
                    label: "Cancel Transaction",
                    onPressed: () => _updateTransactionStatus("Cancelled"),
                  ),
                ),
              ),
            ],
            if (isRenter && isLent && isEndDateToday) ...[
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.6,
                  child: CustomButton(
                    label: "Generate Transaction Code",
                    onPressed: _generateTransactionCode,
                  ),
                ),
              ),
              if (_generatedCode != null)
                Center(child: Text("Generated Code: $_generatedCode")),
            ],
            if (isOwner && isLent && isEndDateToday) ...[
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.4,
                  child: CustomButton(
                    label: "Input Code",
                    onPressed: _showInputDialog,
                  ),
                ),
              ),
            ],
            if (shouldShowReviewButton) ...[
              const SizedBox(height: 20),
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.4,
                  child: CustomButton(
                    label: "Leave a Review",
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewScreen(
                            transaction: widget.transaction,
                          ),
                        ),
                      );
                      setState(() {
                        if (_userId == widget.transaction.renterId) {
                          widget.transaction.hasReviewedByRenter = true;
                        } else if (_userId == widget.transaction.ownerId) {
                          widget.transaction.hasReviewedByLender = true;
                        }
                      });
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
