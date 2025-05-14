class Listing {
  String id;
  String title;
  String description;
  String category;
  String type; // "Products for Rent" or "Services for Hire"
  double? rating; // Average rating
  int? ratingCount; // Number of ratings
  double price;
  String priceUnit;
  String userId; // User who posted the listing
  DateTime timestamp; // Time when the listing was created
  List<String> images; // List of image URLs

  // New fields
  String? preferredTransaction;
  String? otherTransaction; // <-- ADD THIS
  String? region;
  String? municipality;
  String? barangay;
  String? visibility; // <-- New field to track if the listing is archived
  List<Map<String, String>>? bookedSchedules; // <-- Add this

  Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    this.rating,
    this.ratingCount,
    required this.price,
    required this.priceUnit,
    required this.userId,
    required this.timestamp,
    required this.images,
    this.preferredTransaction,
    this.otherTransaction, // <-- ADD THIS
    this.region,
    this.municipality,
    this.barangay,
    this.visibility, // Default value is false (not archived)
    this.bookedSchedules, // <-- Add this
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "category": category,
        "type": type,
        "rating": rating,
        "ratingCount": ratingCount,
        "price": price,
        "priceUnit": priceUnit,
        "userId": userId,
        "timestamp": timestamp.toIso8601String(),
        "images": images,
        "preferredTransaction": preferredTransaction,
        "otherTransaction": otherTransaction, // <-- ADD THIS
        "region": region,
        "municipality": municipality,
        "barangay": barangay,
        "visibility": visibility, // <-- Include the new field in the JSON
        "bookedSchedules": bookedSchedules, // <-- Add this
      };

  static Listing fromJson(Map<String, dynamic> json) => Listing(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        category: json["category"],
        type: json["type"],
        rating: json["rating"]?.toDouble(),
        ratingCount: json["ratingCount"],
        price: json["price"].toDouble(),
        priceUnit: json["priceUnit"],
        userId: json["userId"],
        timestamp: DateTime.parse(json["timestamp"]),
        images: List<String>.from(json["images"] ?? []),
        preferredTransaction: json["preferredTransaction"],
        otherTransaction: json["otherTransaction"], // <-- ADD THIS
        region: json["region"],
        municipality: json["municipality"],
        barangay: json["barangay"],
        visibility: json["visibility"], // <-- Default to false if not present
        bookedSchedules: json["bookedSchedules"] != null
            ? List<Map<String, String>>.from((json["bookedSchedules"] as List)
                .map((item) => Map<String, String>.from(item)))
            : null,
      );

  static Listing fromMap(Map<String, dynamic> map) => fromJson(map);

  Listing copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? type,
    double? rating,
    int? ratingCount,
    double? price,
    String? priceUnit,
    String? userId,
    DateTime? timestamp,
    List<String>? images,
    String? preferredTransaction,
    String? otherTransaction, // <-- ADD THIS
    String? region,
    String? municipality,
    String? barangay,
    String? visibility, // <-- Allow updating the archived status
    List<Map<String, String>>? bookedSchedules, // <-- Add this
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      price: price ?? this.price,
      priceUnit: priceUnit ?? this.priceUnit,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      images: images ?? this.images,
      preferredTransaction: preferredTransaction ?? this.preferredTransaction,
      otherTransaction:
          otherTransaction ?? this.otherTransaction, // <-- ADD THIS
      region: region ?? this.region,
      municipality: municipality ?? this.municipality,
      barangay: barangay ?? this.barangay,
      visibility: visibility ?? this.visibility, // <-- Update archived status
      bookedSchedules: bookedSchedules ?? this.bookedSchedules, // <-- Add this
    );
  }
}
