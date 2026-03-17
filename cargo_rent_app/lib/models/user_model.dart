class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String verificationStatus;
  final String? businessLicense;
  final String? idProofUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.verificationStatus,
    this.businessLicense,
    this.idProofUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'customer',
      verificationStatus: json['verificationStatus'] ?? 'unverified',
      businessLicense: json['businessLicense'],
      idProofUrl: json['idProofUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
      'verificationStatus': verificationStatus,
      'businessLicense': businessLicense,
      'idProofUrl': idProofUrl,
    };
  }

  bool get isCustomer => role == 'customer';
  bool get isVendor => role == 'vendor';
  bool get isAdmin => role == 'admin';
  bool get isApprovedVendor => isVendor && verificationStatus == 'approved';
}