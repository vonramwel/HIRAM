class ReviewModel {
  final String renterId;
  final String lenderId;
  final DateTime date;
  final int rating;
  final String comment;
  final String reviewedBy;
  final String transactionId;
  final String listingId;
  final List<String> imageUrls; // ✅ Added

  ReviewModel({
    required this.renterId,
    required this.lenderId,
    required this.date,
    required this.rating,
    required this.comment,
    required this.reviewedBy,
    required this.transactionId,
    required this.listingId,
    this.imageUrls = const [], // ✅ Added
  });

  Map<String, dynamic> toMap() {
    return {
      'renterId': renterId,
      'lenderId': lenderId,
      'date': date.toIso8601String(),
      'rating': rating,
      'comment': comment,
      'reviewedBy': reviewedBy,
      'transactionId': transactionId,
      'listingId': listingId,
      'imageUrls': imageUrls, // ✅ Added
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      renterId: map['renterId'],
      lenderId: map['lenderId'],
      date: DateTime.parse(map['date']),
      rating: map['rating'],
      comment: map['comment'],
      reviewedBy: map['reviewedBy'],
      transactionId: map['transactionId'],
      listingId: map['listingId'],
      imageUrls: List<String>.from(map['imageUrls'] ?? []), // ✅ Added
    );
  }
}
