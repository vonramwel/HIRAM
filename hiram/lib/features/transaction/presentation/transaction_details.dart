import 'package:flutter/material.dart';
import '../service/transaction_service.dart';
import '../model/transaction_model.dart';
import '../../auth/service/auth.dart';

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
  String? _lenderName;
  final TransactionService _transactionService = TransactionService();

  @override
  void initState() {
    super.initState();
    _fetchUserId();
    _fetchLenderName();
  }

  Future<void> _fetchUserId() async {
    String? userId = await AuthMethods().getCurrentUserId();
    setState(() {
      _userId = userId;
    });
  }

  Future<void> _fetchLenderName() async {
    DocumentSnapshot lenderSnapshot = await FirebaseFirestore.instance
        .collection('User')
        .doc(widget.transaction.ownerId)
        .get();

    setState(() {
      _lenderName = lenderSnapshot['name'];
    });
  }

  void _generateTransactionCode() async {
    String code = await _transactionService
        .generateTransactionCode(widget.transaction.transactionId);
    setState(() {
      _generatedCode = code;
    });
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
                  widget.transaction.status);
              if (isValid && widget.transaction.status == "Approved") {
                setState(() {
                  widget.transaction.status = "Lent";
                });
                Navigator.pop(context);
              }

              if (isValid && widget.transaction.status == "Lent") {
                setState(() {
                  widget.transaction.status = "Completed";
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  void _updateTransactionStatus(String newStatus) async {
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
            Text("Lender Name: ${_lenderName ?? 'Loading...'}"),
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
