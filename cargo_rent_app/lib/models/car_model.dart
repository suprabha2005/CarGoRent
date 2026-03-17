class Car {
  final String id;
  final String name;
  final String brand;
  final String type;
  final double pricePerDay;
  final String imageUrl;
  final String description; // ✅ ADDED
  final bool isAvailable;
  final String vendorId;

  Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.type,
    required this.pricePerDay,
    required this.imageUrl,
    this.description = '', // ✅ optional with default
    required this.isAvailable,
    required this.vendorId,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    // ✅ vendorId can be a String OR a populated object {_id, name}
    String parsedVendorId = '';
    final rawVendor = json['vendorId'];
    if (rawVendor is Map) {
      parsedVendorId = rawVendor['_id'] ?? '';
    } else if (rawVendor is String) {
      parsedVendorId = rawVendor;
    }

    return Car(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      type: json['type'] ?? '',
      pricePerDay: (json['pricePerDay'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '', // ✅ ADDED
      isAvailable: json['isAvailable'] ?? true,
      vendorId: parsedVendorId,
    );
  }

  Car copyWith({
    String? id,
    String? name,
    String? brand,
    String? type,
    double? pricePerDay,
    String? imageUrl,
    String? description,
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
      description: description ?? this.description, // ✅ ADDED
      isAvailable: isAvailable ?? this.isAvailable,
      vendorId: vendorId ?? this.vendorId,
    );
  }
}