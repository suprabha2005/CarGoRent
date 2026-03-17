class Validators {
  // ── Email ─────────────────────────────────────────────
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // ── Password ──────────────────────────────────────────
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // ── Name ─────────────────────────────────────────────
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  // ── Phone ─────────────────────────────────────────────
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(value.trim().replaceAll(' ', '').replaceAll('+91', ''))) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  // ── Required field ────────────────────────────────────
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // ── License number ────────────────────────────────────
  static String? licenseNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'License number is required';
    }
    if (value.trim().length < 8) {
      return 'Enter a valid license number';
    }
    return null;
  }

  // ── Price ─────────────────────────────────────────────
  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value.trim());
    if (price == null || price <= 0) {
      return 'Enter a valid price';
    }
    return null;
  }

  // ── Admin code ────────────────────────────────────────
  static String? adminCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Admin code is required';
    }
    return null;
  }
}