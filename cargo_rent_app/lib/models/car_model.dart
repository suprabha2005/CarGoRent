class Car {
  final String id;
  final String name;
  final String brand;
  final String type;
  final double pricePerDay;
  final String imageUrl;
  final bool isAvailable;
  final String vendorId;

  Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.type,
    required this.pricePerDay,
    required this.imageUrl,
    required this.isAvailable,
    required this.vendorId,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      type: json['type'] ?? '',
      pricePerDay: (json['pricePerDay'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
      vendorId: json['vendorId'] ?? '',
    );
  }

  // Added copyWith method to fix the compilation error
  Car copyWith({
    String? id,
    String? name,
    String? brand,
    String? type,
    double? pricePerDay,
    String? imageUrl,
    bool? isAvailable,
    String? vendorId,
  }) {
    return Car(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      type: type ?? this.type,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      vendorId: vendorId ?? this.vendorId,
    );
  }
}