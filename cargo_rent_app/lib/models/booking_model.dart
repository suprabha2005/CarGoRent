class Booking {
  final String id;
  final String carId;
  final String customerId;
  final String vendorId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String status;
  final String paymentMethod;
  final Map<String, dynamic>? addOns;
  final Map<String, dynamic>? customerDetails;

  Booking({
    required this.id,
    required this.carId,
    required this.customerId,
    required this.vendorId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    required this.paymentMethod,
    this.addOns,
    this.customerDetails,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'] ?? '',
      carId: json['carId'] is Map ? json['carId']['_id'] ?? '' : json['carId'] ?? '',
      customerId: json['customerId'] ?? '',
      vendorId: json['vendorId'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      paymentMethod: json['paymentMethod'] ?? 'cash',
      addOns: json['addOns'],
      customerDetails: json['customerDetails'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'carId': carId,
      'customerId': customerId,
      'vendorId': vendorId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalPrice': totalPrice,
      'status': status,
      'paymentMethod': paymentMethod,
      'addOns': addOns,
      'customerDetails': customerDetails,
    };
  }

  int get durationDays => endDate.difference(startDate).inDays + 1;

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isPaid => status == 'paid';
}