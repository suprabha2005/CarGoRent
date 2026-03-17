import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/car_model.dart';
import '../../services/api_service.dart';

class BookingFlowScreen extends StatefulWidget {
  final Car car;
  final DateTimeRange dateRange;

  const BookingFlowScreen({
    super.key,
    required this.car,
    required this.dateRange,
  });

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  final ApiService _apiService = ApiService();
  int _step = 0;

  final Color navy = const Color(0xFF0F172A);
  final Color gold = const Color(0xFFFFD700);
  final Color blue = const Color(0xFF0052CC);

  bool _addInsurance = false;
  bool _addDriver = false;
  bool _addGPS = false;
  bool _addChildSeat = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _licenseController = TextEditingController();
  String _idType = 'Aadhaar';
  bool _agreedToTerms = false;

  String _paymentMethod = 'online';
  bool _isSubmitting = false;

  int get _days => widget.dateRange.end.difference(widget.dateRange.start).inDays + 1;
  double get _baseFare => widget.car.pricePerDay * _days;
  double get _insuranceFee => _addInsurance ? 299.0 * _days : 0.0;
  double get _driverFee => _addDriver ? 500.0 * _days : 0.0;
  double get _gpsFee => _addGPS ? 99.0 * _days : 0.0;
  double get _childSeatFee => _addChildSeat ? 149.0 * _days : 0.0;
  double get _totalExtras => _insuranceFee + _driverFee + _gpsFee + _childSeatFee;
  double get _subtotal => _baseFare + _totalExtras;
  double get _tax => _subtotal * 0.18;
  double get _total => _subtotal + _tax;

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return "${d.day} ${months[d.month - 1]} ${d.year}";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _submitBooking() async {
    setState(() => _isSubmitting = true);

    final result = await _apiService.createBooking({
      "carId": widget.car.id,
      "vendorId": widget.car.vendorId,
      "startDate": widget.dateRange.start.toIso8601String(),
      "endDate": widget.dateRange.end.toIso8601String(),
      "totalPrice": _total,
      "addOns": {
        "insurance": _addInsurance,
        "driver": _addDriver,
        "gps": _addGPS,
        "childSeat": _addChildSeat,
      },
      "paymentMethod": _paymentMethod,
      "customerDetails": {
        "name": _nameController.text,
        "phone": _phoneController.text,
        "email": _emailController.text,
        "licenseNumber": _licenseController.text,
      },
    });

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result["success"] == true) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("❌ ${result['message'] ?? 'Booking failed'}"),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green.shade200, width: 2),
                ),
                child: const Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 20),
              const Text("Booking Requested! 🎉",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(
                "Your booking request for ${widget.car.name} has been sent to the vendor.\nYou'll be notified once confirmed.",
                style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _summaryRow("Car", widget.car.name),
                    _summaryRow("Pickup", _formatDate(widget.dateRange.start)),
                    _summaryRow("Return", _formatDate(widget.dateRange.end)),
                    _summaryRow("Days", "$_days"),
                    const Divider(height: 16),
                    _summaryRow("Total Paid", "₹${_total.toStringAsFixed(0)}", bold: true, color: blue),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navy,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Back to Home",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 6, child: _buildMainContent()),
                Container(width: 1, color: Colors.grey.shade200),
                Expanded(flex: 3, child: _buildSummaryPanel()),
              ],
            )
          : Column(
              children: [
                Expanded(flex: 6, child: _buildMainContent()),
                Expanded(flex: 4, child: _buildSummaryPanel()),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: navy,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Row(
        children: [
          Icon(Icons.directions_car_outlined, color: gold, size: 20),
          const SizedBox(width: 8),
          const Text("Book Your Ride",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
        ],
      ),
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: _buildStepper(),
      ),
    );
  }

  Widget _buildStepper() {
    final steps = ["OPTIONS", "DETAILS", "PAYMENT"];
    return Container(
      color: navy,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(
        children: steps.asMap().entries.map((e) {
          final isDone = e.key < _step;
          final isActive = e.key == _step;
          final isLast = e.key == steps.length - 1;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: e.key < _step ? () => setState(() => _step = e.key) : null,
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isDone ? Colors.green : (isActive ? gold : Colors.white.withOpacity(0.1)),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDone ? Colors.green : (isActive ? gold : Colors.white24),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: isDone
                                ? const Icon(Icons.check, color: Colors.white, size: 15)
                                : Text("${e.key + 1}",
                                    style: TextStyle(
                                        color: isActive ? navy : Colors.white54,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(e.value,
                            style: TextStyle(
                                color: isActive ? gold : (isDone ? Colors.green : Colors.white38),
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5)),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_step == 0) _buildOptionsStep(),
          if (_step == 1) _buildDetailsStep(),
          if (_step == 2) _buildPaymentStep(),
          const SizedBox(height: 24),
          _buildNavButtons(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildOptionsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader("Rental Add-ons", "Customize your experience"),
        const SizedBox(height: 20),
        _sectionLabel("Per Day Extras"),
        const SizedBox(height: 10),
        _addonCard(
          icon: Icons.shield_outlined,
          title: "Comprehensive Insurance",
          subtitle: "Full coverage for damage, theft & accidents",
          price: "₹299/day",
          value: _addInsurance,
          color: Colors.blue,
          onChanged: (v) => setState(() => _addInsurance = v),
        ),
        _addonCard(
          icon: Icons.gps_fixed,
          title: "GPS Navigation",
          subtitle: "Never get lost with real-time navigation",
          price: "₹99/day",
          value: _addGPS,
          color: Colors.purple,
          onChanged: (v) => setState(() => _addGPS = v),
        ),
        const SizedBox(height: 20),
        _sectionLabel("One-time Extras"),
        const SizedBox(height: 10),
        _addonCard(
          icon: Icons.person_outlined,
          title: "Additional Driver",
          subtitle: "Add a second driver to the rental",
          price: "₹500/day",
          value: _addDriver,
          color: Colors.orange,
          onChanged: (v) => setState(() => _addDriver = v),
        ),
        _addonCard(
          icon: Icons.child_care,
          title: "Child Safety Seat",
          subtitle: "Certified baby/toddler safety seat",
          price: "₹149/day",
          value: _addChildSeat,
          color: Colors.pink,
          onChanged: (v) => setState(() => _addChildSeat = v),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05);
  }

  Widget _addonCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String price,
    required bool value,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: value ? color.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? color.withOpacity(0.5) : Colors.grey.shade200,
            width: value ? 1.5 : 1,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price, style: TextStyle(color: blue, fontWeight: FontWeight.w900, fontSize: 13)),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: value ? color : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: value ? color : Colors.grey.shade300, width: 2),
                  ),
                  child: value ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader("Your Details", "We need a few details to confirm your booking"),
        const SizedBox(height: 20),
        _fieldLabel("Full Name"),
        _inputField(_nameController, "e.g. Rahul Sharma", Icons.person_outline),
        const SizedBox(height: 16),
        _fieldLabel("Phone Number"),
        _inputField(_phoneController, "e.g. +91 98765 43210", Icons.phone_outlined,
            type: TextInputType.phone),
        const SizedBox(height: 16),
        _fieldLabel("Email Address"),
        _inputField(_emailController, "e.g. rahul@gmail.com", Icons.email_outlined,
            type: TextInputType.emailAddress),
        const SizedBox(height: 16),
        _fieldLabel("ID Type"),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _idType,
              isExpanded: true,
              items: ['Aadhaar', 'PAN Card', 'Passport', 'Driving License']
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) => setState(() => _idType = v!),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _fieldLabel("Driving License Number"),
        _inputField(_licenseController, "e.g. MH12-20240001234", Icons.credit_card_outlined),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: _agreedToTerms ? navy : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: _agreedToTerms ? navy : Colors.grey.shade400),
                ),
                child: _agreedToTerms
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "I agree to the Rental Terms & Conditions, including the damage policy and cancellation terms.",
                  style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05);
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: navy)),
    );
  }

  Widget _inputField(TextEditingController ctrl, String hint, IconData icon,
      {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: Icon(icon, size: 20, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: blue, width: 1.5)),
      ),
    );
  }

  Widget _buildPaymentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader("Payment", "Choose how you'd like to pay"),
        const SizedBox(height: 20),
        _paymentOption('online', Icons.credit_card_outlined, 'Pay Online',
            'Credit / Debit Card, UPI, Net Banking', Colors.blue),
        const SizedBox(height: 10),
        _paymentOption('cash', Icons.money_outlined, 'Pay at Pickup',
            'Pay cash when you collect the car', Colors.green),
        const SizedBox(height: 24),
        _sectionLabel("Price Breakdown"),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _summaryRow("Base Fare (${widget.car.name} × $_days days)", "₹${_baseFare.toStringAsFixed(0)}"),
              if (_addInsurance) _summaryRow("Insurance (₹299 × $_days)", "₹${_insuranceFee.toStringAsFixed(0)}"),
              if (_addDriver) _summaryRow("Additional Driver (₹500 × $_days)", "₹${_driverFee.toStringAsFixed(0)}"),
              if (_addGPS) _summaryRow("GPS Navigation (₹99 × $_days)", "₹${_gpsFee.toStringAsFixed(0)}"),
              if (_addChildSeat) _summaryRow("Child Safety Seat (₹149 × $_days)", "₹${_childSeatFee.toStringAsFixed(0)}"),
              const Divider(height: 20),
              _summaryRow("Subtotal", "₹${_subtotal.toStringAsFixed(0)}"),
              _summaryRow("GST (18%)", "₹${_tax.toStringAsFixed(0)}"),
              const Divider(height: 20),
              _summaryRow("Total Amount", "₹${_total.toStringAsFixed(0)}", bold: true, color: blue),
            ],
          ),
        ),
        if (_paymentMethod == 'online') ...[
          const SizedBox(height: 20),
          _sectionLabel("Secure Payment"),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_outlined, color: blue, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "Payments are secured with 256-bit SSL encryption. Your card details are never stored.",
                    style: TextStyle(fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05);
  }

  Widget _paymentOption(String value, IconData icon, String title, String subtitle, Color color) {
    final isSelected = _paymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: 2),
              ),
              child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 13) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButtons() {
    final canProceed = _step == 1
        ? (_nameController.text.isNotEmpty &&
            _phoneController.text.isNotEmpty &&
            _emailController.text.isNotEmpty &&
            _licenseController.text.isNotEmpty &&
            _agreedToTerms)
        : true;

    return Row(
      children: [
        if (_step > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _step--),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: navy),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text("← Back", style: TextStyle(color: navy, fontWeight: FontWeight.w900)),
            ),
          ),
        if (_step > 0) const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: canProceed
                ? () {
                    if (_step < 2) {
                      setState(() => _step++);
                    } else {
                      _submitBooking();
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _step == 2 ? Colors.green : navy,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : Text(
                    _step == 2 ? "✓ CONFIRM BOOKING" : "NEXT →",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5),
                  ),
          ),
        ),
      ],
    );
  }

  // ── Summary Panel ─────────────────────────────────────────────────

  Widget _buildSummaryPanel() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("YOUR RENTAL",
                style: TextStyle(
                    color: navy, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 140,
                width: double.infinity,
                color: const Color(0xFFF0F4FF),
                child: Image.network(
                  widget.car.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.directions_car, size: 60, color: Colors.grey.shade400),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(widget.car.name,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            Text("${widget.car.brand} · ${widget.car.type}",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            _infoRow(Icons.calendar_today_outlined, "Pickup", _formatDate(widget.dateRange.start)),
            const SizedBox(height: 8),
            _infoRow(Icons.event_available_outlined, "Return", _formatDate(widget.dateRange.end)),
            const SizedBox(height: 8),
            _infoRow(Icons.access_time_outlined, "Duration", "$_days day${_days > 1 ? 's' : ''}"),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            _summaryRow("Base Fare", "₹${_baseFare.toStringAsFixed(0)}"),
            if (_totalExtras > 0) _summaryRow("Add-ons", "₹${_totalExtras.toStringAsFixed(0)}"),
            _summaryRow("GST (18%)", "₹${_tax.toStringAsFixed(0)}"),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("TOTAL", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                Text("₹${_total.toStringAsFixed(0)}",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: blue)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer_outlined, color: Colors.orange.shade700, size: 16),
                  const SizedBox(width: 8),
                  Text("Complete booking within 15 mins",
                      style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ), // ✅ closes Column
      ),   // ✅ closes SingleChildScrollView
    );     // ✅ closes Container
  }

  // ── Helpers ───────────────────────────────────────────────────────

  Widget _stepHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: navy)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        const SizedBox(height: 4),
        Container(width: 40, height: 3, decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(2))),
      ],
    );
  }

  Widget _sectionLabel(String label) {
    return Text(label,
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: navy.withOpacity(0.7)));
  }

  Widget _summaryRow(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: bold ? navy : Colors.grey.shade600,
              fontWeight: bold ? FontWeight.w900 : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 13, color: color ?? (bold ? navy : Colors.black87),
              fontWeight: bold ? FontWeight.w900 : FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }
}