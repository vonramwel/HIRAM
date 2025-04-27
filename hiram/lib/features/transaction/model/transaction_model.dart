import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String transactionId;
  final String listingId;
  final String renterId;
  final String ownerId;
  final DateTime startDate;
  final DateTime endDate;
  final String paymentMethod;
  final String notes;
  String status;
  final Timestamp timestamp;
  String transactionCode;
  double? transactionRating;
  double totalPrice;
  double? offeredPrice; // <-- Add this line

  bool hasReviewedByRenter;
  bool hasReviewedByLender;

  TransactionModel({
    required this.transactionId,
    required this.listingId,
    required this.renterId,
    required this.ownerId,
    required this.startDate,
    required this.endDate,
    required this.paymentMethod,
    required this.notes,
    required this.status,
    required this.timestamp,
    required this.totalPrice,
    this.offeredPrice, // <-- Add this line
    this.transactionCode = '',
    this.transactionRating,
    this.hasReviewedByRenter = false,
    this.hasReviewedByLender = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'listingId': listingId,
      'renterId': renterId,
      'ownerId': ownerId,
      'startDate': startDate,
      'endDate': endDate,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'status': status,
      'timestamp': timestamp,
      'totalPrice': totalPrice,
      'offeredPrice': offeredPrice, // <-- Save offered price
      'transactionCode': transactionCode,
      'transactionRating': transactionRating,
      'hasReviewedByRenter': hasReviewedByRenter,
      'hasReviewedByLender': hasReviewedByLender,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      transactionId: map['transactionId'] ?? '',
      listingId: map['listingId'] ?? '',
      renterId: map['renterId'] ?? '',
      ownerId: map['ownerId'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      paymentMethod: map['paymentMethod'] ?? '',
      notes: map['notes'] ?? '',
      status: map['status'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      offeredPrice: map['offeredPrice'] != null
          ? (map['offeredPrice']).toDouble()
          : null, // <-- Load offeredPrice
      transactionCode: map['transactionCode'] ?? '',
      transactionRating: map['transactionRating'] != null
          ? (map['transactionRating']).toDouble()
          : null,
      hasReviewedByRenter: map['hasReviewedByRenter'] ?? false,
      hasReviewedByLender: map['hasReviewedByLender'] ?? false,
    );
  }
}
