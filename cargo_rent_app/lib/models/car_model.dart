class Car {
  final String id;
  final String name;
  final String brand;
  final double pricePerDay;
  final String imageUrl;
  final String type;
  final bool isAvailable;

  // ADD THE 'const' KEYWORD HERE
  const Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.pricePerDay,
    required this.imageUrl,
    required this.type,
    this.isAvailable = true,
  });
}