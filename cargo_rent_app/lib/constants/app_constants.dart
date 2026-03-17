class AppConstants {
  // ── API ──────────────────────────────────────────────
  static const String baseUrl = "http://localhost:5000/api";

  // ── User Roles ───────────────────────────────────────
  static const String roleCustomer = "customer";
  static const String roleVendor = "vendor";
  static const String roleAdmin = "admin";

  // ── Booking Status ───────────────────────────────────
  static const String statusPending = "pending";
  static const String statusApproved = "approved";
  static const String statusRejected = "rejected";
  static const String statusPaid = "paid";

  // ── Verification Status ──────────────────────────────
  static const String verificationUnverified = "unverified";
  static const String verificationPending = "pending";
  static const String verificationApproved = "approved";

  // ── Route Names ──────────────────────────────────────
  static const String routeLanding = "/landing";
  static const String routeLogin = "/login";
  static const String routeRegister = "/register";
  static const String routeHome = "/home";
  static const String routeVehicles = "/vehicles";
  static const String routeVendorDashboard = "/vendor_dashboard";
  static const String routeVendorVerification = "/vendor_verification";
  static const String routeVendorPending = "/vendor_pending";
  static const String routeAdminDashboard = "/admin_dashboard";

  // ── Add-on Prices ────────────────────────────────────
  static const double insurancePricePerDay = 299.0;
  static const double driverPricePerDay = 500.0;
  static const double gpsPricePerDay = 99.0;
  static const double childSeatPricePerDay = 149.0;

  // ── Tax ──────────────────────────────────────────────
  static const double gstRate = 0.18;

  // ── App Info ─────────────────────────────────────────
  static const String appName = "CarGoRent";
  static const String appTagline = "India's trusted car rental";
}