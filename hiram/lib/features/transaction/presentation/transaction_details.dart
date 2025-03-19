import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/transaction_model.dart';
import '../../auth/service/auth.dart';

class TransactionDetails extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionDetails({super.key, required this.transaction});

  @override
  _TransactionDetailsState createState() => _TransactionDetailsState();
}

class _TransactionDetailsState extends State<TransactionDetails> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    String? userId = await AuthMethods().getCurrentUserId();
    setState(() {
      _userId = userId;
    });
  }

  Future<void> _updateTransactionStatus(String newStatus) async {
    await FirebaseFirestore.instance
        .collection('transactions')
        .where('listingId', isEqualTo: widget.transaction.listingId)
        .where('renterId', isEqualTo: widget.transaction.renterId)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.update({'status': newStatus});
      }
    });

    setState(() {
      widget.transaction.status = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isOwner = _userId == widget.transaction.ownerId;
    bool isRenter = _userId == widget.transaction.renterId;

    return Scaffold(
      appBar: AppBar(title: const Text("Transaction Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Payment Method: ${widget.transaction.paymentMethod}"),
            Text("Start Date: ${widget.transaction.startDate.toLocal()}"),
            Text("End Date: ${widget.transaction.endDate.toLocal()}"),
            Text("Notes: ${widget.transaction.notes}"),
            Text("Status: ${widget.transaction.status}"),
            const SizedBox(height: 20),
            if (isOwner)
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _updateTransactionStatus("Approved"),
                    child: const Text("Approve"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _updateTransactionStatus("Disapproved"),
                    child: const Text("Disapprove"),
                  ),
                ],
              ),
            if (isRenter)
              ElevatedButton(
                onPressed: () => _updateTransactionStatus("Cancelled"),
                child: const Text("Cancel Transaction"),
              ),
          ],
        ),
      ),
    );
  }
}
