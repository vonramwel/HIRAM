class Listing {
  String id;
  String title;
  String description;
  String category;
  String type; // "product" or "service"
  double? rating; // Initially null
  double price;
  String priceUnit;
  String userId; // User who posted the listing
  DateTime timestamp; // Time when the listing was created
  List<String> images; // List of image URLs

  Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    this.rating,
    required this.price,
    required this.priceUnit, // Added priceUnit
    required this.userId,
    required this.timestamp,
    required this.images, // Initialize images
  });

  // Convert Listing to JSON
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "category": category,
        "type": type,
        "rating": rating,
        "price": price,
        "priceUnit": priceUnit, // Store priceUnit
        "userId": userId,
        "timestamp": timestamp.toIso8601String(),
        "images": images, // Store image URLs
      };

  // Create Listing from JSON
  static Listing fromJson(Map<String, dynamic> json) => Listing(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        category: json["category"],
        type: json["type"],
        rating: json["rating"]?.toDouble(),
        price: json["price"].toDouble(),
        priceUnit: json["priceUnit"], // Retrieve priceUnit
        userId: json["userId"],
        timestamp: DateTime.parse(json["timestamp"]),
        images: List<String>.from(json["images"] ?? []), // Retrieve images
      );
}
