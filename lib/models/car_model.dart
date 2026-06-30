class CarModel {
  final String id;
  final String make;
  final String model;
  final int year;
  final double price;
  final int mileage;
  final String transmission;
  final String fuelType;
  final String category;
  final String dealer;
  final double rating;
  final String imageUrl;
  final String description;
  final List<String> features;
  final bool isFavorite;
  final int? previousPrice;
  final String? sellerId;
  final String? sellerName;
  final String? sellerPhone;

  CarModel({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.price,
    required this.mileage,
    required this.transmission,
    required this.fuelType,
    required this.category,
    required this.dealer,
    required this.rating,
    required this.imageUrl,
    required this.description,
    required this.features,
    this.isFavorite = false,
    this.previousPrice,
    this.sellerId,
    this.sellerName,
    this.sellerPhone,
  });

  String get fullName => '$year $make $model';

  factory CarModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return CarModel(
      id: docId,
      make: data['make'] ?? '',
      model: data['model'] ?? '',
      year: (data['year'] as num?)?.toInt() ?? 0,
      price: (data['price'] as num?)?.toDouble() ?? 0,
      mileage: (data['mileage'] as num?)?.toInt() ?? 0,
      transmission: data['transmission'] ?? 'Automatic',
      fuelType: data['fuelType'] ?? 'Gasoline',
      category: data['category'] ?? 'Sedan',
      dealer: data['sellerName'] ?? data['dealer'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      features: List<String>.from(data['features'] ?? []),
      sellerId: data['sellerId'],
      sellerName: data['sellerName'],
      sellerPhone: data['sellerPhone'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'make': make,
      'model': model,
      'year': year,
      'price': price,
      'mileage': mileage,
      'transmission': transmission,
      'fuelType': fuelType,
      'category': category,
      'description': description,
      'features': features,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'sellerName': sellerName ?? dealer,
      'sellerPhone': sellerPhone,
      'rating': rating,
    };
  }

  CarModel copyWith({bool? isFavorite}) {
    return CarModel(
      id: id,
      make: make,
      model: model,
      year: year,
      price: price,
      mileage: mileage,
      transmission: transmission,
      fuelType: fuelType,
      category: category,
      dealer: dealer,
      rating: rating,
      imageUrl: imageUrl,
      description: description,
      features: features,
      isFavorite: isFavorite ?? this.isFavorite,
      previousPrice: previousPrice,
      sellerId: sellerId,
      sellerName: sellerName,
      sellerPhone: sellerPhone,
    );
  }
}