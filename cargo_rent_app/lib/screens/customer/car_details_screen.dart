import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../models/car_model.dart';
import 'booking_flow_screen.dart';

class CarDetailsScreen extends StatefulWidget {
  // ✅ FIXED: Strongly typed Car model instead of dynamic
  final Car car;
  const CarDetailsScreen({super.key, required this.car});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  final ApiService _apiService = ApiService();
  DateTimeRange? _selectedRange;
  List<Map<String, dynamic>> _bookedRanges = [];
  bool _loadingDates = false;

  // Brand Colors
  final Color primaryBlue = const Color(0xFF0052CC);
  final Color accentGold = const Color(0xFFFFD700);
  final Color navyDark = const Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _loadBookedDates();
  }

  Future<void> _loadBookedDates() async {
    setState(() => _loadingDates = true);
    _bookedRanges = await _apiService.fetchBookedDates(widget.car.id);
    if (mounted) setState(() => _loadingDates = false);
  }

  // Returns true if a given day falls within any booked range
  bool _isDateBooked(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    for (final range in _bookedRanges) {
      final start = DateTime.parse(range['startDate']).toLocal();
      final end = DateTime.parse(range['endDate']).toLocal();
      final s = DateTime(start.year, start.month, start.day);
      final e = DateTime(end.year, end.month, end.day);
      if (!d.isBefore(s) && !d.isAfter(e)) return true;
    }
    return false;
  }

  // Returns true if a selected range overlaps any booked range
  bool _rangeOverlaps(DateTimeRange range) {
    for (final b in _bookedRanges) {
      final bs = DateTime.parse(b['startDate']).toLocal();
      final be = DateTime.parse(b['endDate']).toLocal();
      if (range.start.isBefore(be) && range.end.isAfter(bs)) return true;
    }
    return false;
  }

  void _selectDates() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      selectableDayPredicate: (day, focused, selected) => !_isDateBooked(day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: navyDark,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Double-check overlap (safety net)
      if (_rangeOverlaps(picked)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("❌ Selected dates overlap with an existing booking. Please choose other dates."),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      setState(() => _selectedRange = picked);
      _showConfirmationDialog();
    }
  }

  void _showConfirmationDialog() {
    // ✅ Navigate to full 3-step booking flow
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingFlowScreen(
          car: widget.car,
          dateRange: _selectedRange!,
        ),
      ),
    );
  }

  Widget _dialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }

  void _confirmBooking(num total) async {
    Navigator.pop(context); // Close dialog

    final vendorId = widget.car.vendorId;

    if (vendorId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Error: Owner information missing for this car."),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating),
        );
      }
      return;
    }

    // ✅ FIXED: createBooking now returns Map with success + actual error message
    final result = await _apiService.createBooking({
      "carId": widget.car.id,
      "vendorId": vendorId,
      "startDate": _selectedRange!.start.toIso8601String(),
      "endDate": _selectedRange!.end.toIso8601String(),
      "totalPrice": total,
    });

    if (!mounted) return;

    if (result["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Booking Request Sent Successfully! 🎉"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating),
      );
      Navigator.pop(context);
    } else {
      // ✅ Shows the ACTUAL error message from backend
      final errorMsg = result["message"] ?? "Failed to create booking. Please try again.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("❌ $errorMsg"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // ── Hero Image AppBar ────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: navyDark,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // ✅ FIXED: dot notation
                  Image.network(
                    widget.car.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFF0F4FF),
                      child: Icon(Icons.directions_car,
                          size: 100, color: Colors.grey.shade400),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                  // Type badge bottom-left
                  Positioned(
                    bottom: 16,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: accentGold,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      // ✅ FIXED: dot notation
                      child: Text(widget.car.type.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Details Content ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ✅ FIXED: dot notation
                            Text(widget.car.name,
                                    style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                        color: navyDark))
                                .animate()
                                .fadeIn(duration: 500.ms)
                                .slideX(begin: -0.2),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.orange, size: 16),
                                const SizedBox(width: 4),
                                const Text("4.8 · Verified Car",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // ✅ FIXED: dot notation
                          Text("₹${widget.car.pricePerDay}",
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: primaryBlue)),
                          const Text("/day",
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Specs row ────────────────────────────────────────
                  Row(
                    children: [
                      _specChip(Icons.directions_car_outlined, widget.car.type),
                      const SizedBox(width: 10),
                      _specChip(Icons.ac_unit_outlined, "AC"),
                      const SizedBox(width: 10),
                      _specChip(Icons.speed_outlined, "Self Drive"),
                    ],
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 20),

                  // ── Description ──────────────────────────────────────
                  Text("About this vehicle",
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: navyDark))
                      .animate()
                      .fadeIn(delay: 300.ms),
                  const SizedBox(height: 10),
                  Text(
                    // ✅ FIXED: dot notation
                    widget.car.description.isNotEmpty
                        ? widget.car.description
                        : "A well-maintained ${widget.car.type} available for self-drive rental. Air-conditioned and serviced regularly for your comfort and safety.",
                    style: const TextStyle(
                        color: Colors.grey, height: 1.6, fontSize: 14),
                  ).animate().fadeIn(delay: 350.ms),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 20),

                  // ── Pricing Breakdown ────────────────────────────────
                  Text("Pricing",
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: navyDark))
                      .animate()
                      .fadeIn(delay: 400.ms),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _pricingRow("Base fare (per day)",
                            "₹${widget.car.pricePerDay}"),
                        const SizedBox(height: 10),
                        _pricingRow("Unlimited kilometres", "FREE"),
                        const SizedBox(height: 10),
                        _pricingRow("Driver fee", "Included"),
                        const Divider(height: 20),
                        _pricingRow("You pay per day",
                            "₹${widget.car.pricePerDay}",
                            bold: true),
                      ],
                    ),
                  ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.2),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 20),

                  // ── Hosted By ────────────────────────────────────────
                  Text("Hosted by",
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: navyDark))
                      .animate()
                      .fadeIn(delay: 500.ms),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: navyDark,
                          radius: 24,
                          child: const Icon(Icons.person,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Verified Vendor",
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15)),
                            Text("Professional Host · CarGoRent Partner",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.verified,
                            color: Colors.green, size: 20),
                      ],
                    ),
                  ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.2),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom Book Button ───────────────────────────────────────────
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 16,
                offset: const Offset(0, -4))
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Price",
                    style: TextStyle(color: Colors.grey, fontSize: 11)),
                // ✅ FIXED: dot notation
                Text("₹${widget.car.pricePerDay}/day",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: primaryBlue)),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: _loadingDates ? null : _selectDates,
                style: ElevatedButton.styleFrom(
                  backgroundColor: navyDark,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: _loadingDates
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_bookedRanges.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "${_bookedRanges.length} dates taken",
                                style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w900),
                              ),
                            ),
                          const Text("CHECK AVAILABILITY & BOOK",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _specChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: primaryBlue),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _pricingRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                color: bold ? const Color(0xFF0F172A) : Colors.grey,
                fontWeight:
                    bold ? FontWeight.w900 : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
                color: bold ? primaryBlue : const Color(0xFF1E293B))),
      ],
    );
  }
}