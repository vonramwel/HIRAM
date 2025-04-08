import 'package:flutter/material.dart';
import '../service/transaction_service.dart';
import '../model/transaction_model.dart';
import '../../auth/service/auth.dart';
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
  String? _lenderName;
  final TransactionService _transactionService = TransactionService();
  bool _hasShownReviewDialog = false;
  late Stream<DocumentSnapshot> _transactionStream;

  @override
  void initState() {
    super.initState();
    _fetchUserId();
    _fetchLenderName();
    _listenToTransactionStatus();
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

  void _listenToTransactionStatus() {
    _transactionStream = FirebaseFirestore.instance
        .collection('transactions')
        .doc(widget.transaction.transactionId)
        .snapshots();
  }

  void _checkForReviewScreen() {
    if (widget.transaction.status == 'Completed') {
      if ((_userId == widget.transaction.renterId &&
              !widget.transaction.hasReviewedByRenter) ||
          (_userId == widget.transaction.ownerId &&
              !widget.transaction.hasReviewedByLender)) {
        // Show the review screen when it's time
        if (!_hasShownReviewDialog) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkForReviewScreen();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('transactions')
            .doc(widget.transaction.transactionId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
                child: Text('Error fetching transaction data.'));
          }

          DocumentSnapshot transactionSnapshot = snapshot.data!;
          var transactionData =
              transactionSnapshot.data() as Map<String, dynamic>;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                "Transaction ID: ${widget.transaction.transactionId}",
                // style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 10),
              Text("Start Date: ${widget.transaction.startDate}"),
              Text("End Date: ${widget.transaction.endDate}"),
              Text("Notes: ${widget.transaction.notes}"),
              const SizedBox(height: 20),
              Text("Owner: $_lenderName"),
              const SizedBox(height: 10),
              Text("Status: ${widget.transaction.status}"),
            ],
          );
        },
      ),
    );
  }
}
