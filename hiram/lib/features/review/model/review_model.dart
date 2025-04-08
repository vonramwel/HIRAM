class ReviewModel {
  final String renterId;
  final String lenderId;
  final DateTime date;
  final int rating;
  final String comment;
  final String reviewedBy; // "renter" or "lender"

  ReviewModel({
    required this.renterId,
    required this.lenderId,
    required this.date,
    required this.rating,
    required this.comment,
    required this.reviewedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'renterId': renterId,
      'lenderId': lenderId,
      'date': date.toIso8601String(),
      'rating': rating,
      'comment': comment,
      'reviewedBy': reviewedBy,
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
    );
  }
}
