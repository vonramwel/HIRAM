import 'package:flutter/material.dart';
import '../service/transaction_service.dart';
import '../model/transaction_model.dart';
import '../../auth/service/auth.dart';
import '../../auth/service/database.dart';
import '../../review/presentation/review_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionDetails extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionDetails({super.key, required this.transaction});

  @override
  _TransactionDetailsState createState() => _TransactionDetailsState();
}

class _TransactionDetailsState extends State<TransactionDetails> {
  String? _userId;
  String? _generatedCode;
  String otherUserName = 'Loading...';
  String otherUserLabel = 'User';
  final TransactionService _transactionService = TransactionService();
  final AuthMethods _authMethods = AuthMethods();
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  bool _hasShownReviewDialog = false;

  @override
  void initState() {
    super.initState();
    _fetchUserId();
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

  Future<void> _fetchOtherUserName(String? currentUserId) async {
    if (currentUserId == null) return;

    String otherUserId = currentUserId == widget.transaction.ownerId
        ? widget.transaction.renterId
        : widget.transaction.ownerId;

    setState(() {
      otherUserLabel =
          currentUserId == widget.transaction.ownerId ? 'Renter' : 'Owner';
    });

    try {
      Map<String, dynamic>? userData =
          await _databaseMethods.getUserData(otherUserId);
      setState(() {
        otherUserName = userData?['name'] ?? 'Unknown User';
      });
    } catch (e) {
      setState(() {
        otherUserName = 'Error loading user';
      });
    }
  }

  void _generateTransactionCode() async {
    String code = await _transactionService
        .generateTransactionCode(widget.transaction.transactionId);
    setState(() {
      _generatedCode = code;
    });
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Code Generated"),
        content: Text("Transaction code: $code"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showInputDialog() {
    TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter Transaction Code"),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(hintText: "Enter 6-digit code"),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              bool isValid = await _transactionService.validateTransactionCode(
                widget.transaction.transactionId,
                codeController.text,
                widget.transaction.status,
              );

              if (isValid && widget.transaction.status == "Approved") {
                await _updateTransactionStatus("Lent");
                Navigator.pop(context);
                _showTransactionCompletedDialog(
                    "Transaction has been marked as Lent.");
              } else if (isValid && widget.transaction.status == "Lent") {
                await _updateTransactionStatus("Completed");
                Navigator.pop(context);
                _showTransactionCompletedDialog(
                    "Transaction has been marked as Completed.");
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Invalid code. Please try again.")),
                );
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  void _showTransactionCompletedDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Success"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _updateTransactionStatus(String newStatus) async {
    await _transactionService.updateTransactionStatus(
      widget.transaction.transactionId,
      widget.transaction.listingId,
      widget.transaction.renterId,
      newStatus,
    );
    setState(() {
      widget.transaction.status = newStatus;
    });

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

    return Scaffold(
      appBar: AppBar(title: const Text("Transaction Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$otherUserLabel Name: $otherUserName"),
            Text("Payment Method: ${widget.transaction.paymentMethod}"),
            Text("Start Date: ${widget.transaction.startDate.toLocal()}"),
            Text("End Date: ${widget.transaction.endDate.toLocal()}"),
            Text("Notes: ${widget.transaction.notes}"),
            Text("Status: ${widget.transaction.status}"),
            const SizedBox(height: 20),
            if (isOwner && isApproved && isStartDateToday) ...[
              ElevatedButton(
                onPressed: _generateTransactionCode,
                child: const Text("Generate Transaction Code"),
              ),
              if (_generatedCode != null)
                Text("Generated Code: $_generatedCode"),
              ElevatedButton(
                onPressed: () => _updateTransactionStatus("Cancelled"),
                child: const Text("Cancel Transaction"),
              ),
            ],
            if (isRenter && isApproved && isStartDateToday) ...[
              ElevatedButton(
                onPressed: _showInputDialog,
                child: const Text("Input Code"),
              ),
            ],
            if (isOwner && !isApproved && !isLent && !isCompleted) ...[
              ElevatedButton(
                onPressed: () => _updateTransactionStatus("Approved"),
                child: const Text("Approve"),
              ),
              ElevatedButton(
                onPressed: () => _updateTransactionStatus("Disapproved"),
                child: const Text("Disapprove"),
              ),
            ],
            if (isRenter && !isApproved && !isLent && !isCompleted) ...[
              ElevatedButton(
                onPressed: () => _updateTransactionStatus("Cancelled"),
                child: const Text("Cancel Transaction"),
              ),
            ],
            if (isRenter && isLent && isEndDateToday) ...[
              ElevatedButton(
                onPressed: _generateTransactionCode,
                child: const Text("Generate Transaction Code"),
              ),
              if (_generatedCode != null)
                Text("Generated Code: $_generatedCode"),
            ],
            if (isOwner && isLent && isEndDateToday) ...[
              ElevatedButton(
                onPressed: _showInputDialog,
                child: const Text("Input Code"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
