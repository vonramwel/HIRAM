import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String listingId;
  final String renterId;
  final String ownerId;
  final DateTime startDate;
  final DateTime endDate;
  final String paymentMethod;
  final String notes;
  final String status;
  final Timestamp timestamp;

  TransactionModel({
    required this.listingId,
    required this.renterId,
    required this.ownerId,
    required this.startDate,
    required this.endDate,
    required this.paymentMethod,
    required this.notes,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'listingId': listingId,
      'renterId': renterId,
      'ownerId': ownerId,
      'startDate': startDate,
      'endDate': endDate,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'status': status,
      'timestamp': timestamp,
    };
  }

  /// **Fix: Add this method to convert Firestore data into a TransactionModel**
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      listingId: map['listingId'] as String,
      renterId: map['renterId'] as String,
      ownerId: map['ownerId'] as String,
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      paymentMethod: map['paymentMethod'] as String,
      notes: map['notes'] as String,
      status: map['status'] as String,
      timestamp: map['timestamp'] as Timestamp,
    );
  }
}
