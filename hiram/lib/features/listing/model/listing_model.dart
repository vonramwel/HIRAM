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

  String? region;
  String? municipality;
  String? barangay;

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
    this.region,
    this.municipality,
    this.barangay,
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
        "region": region,
        "municipality": municipality,
        "barangay": barangay,
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
        region: json["region"],
        municipality: json["municipality"],
        barangay: json["barangay"],
      );
  static Listing fromMap(Map<String, dynamic> map) => fromJson(map);
}
