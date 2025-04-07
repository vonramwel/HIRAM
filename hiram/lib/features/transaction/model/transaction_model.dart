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
    this.transactionCode = '',
    this.transactionRating,
  });

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'listingId': listingId,
      'renterId': renterId,
      'ownerId': ownerId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'paymentMethod': paymentMethod,
      'notes': notes,
      'status': status,
      'timestamp': timestamp,
      'transactionCode': transactionCode,
      'transactionRating': transactionRating,
      'totalPrice': totalPrice,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      transactionId: map['transactionId'] as String,
      listingId: map['listingId'] as String,
      renterId: map['renterId'] as String,
      ownerId: map['ownerId'] as String,
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      paymentMethod: map['paymentMethod'] as String,
      notes: map['notes'] as String,
      status: map['status'] as String,
      timestamp: map['timestamp'] as Timestamp,
      transactionCode: map['transactionCode'] ?? '',
      transactionRating: (map['transactionRating'] as num?)?.toDouble(),
      totalPrice: (map['totalPrice'] as num).toDouble(),
    );
  }
}
