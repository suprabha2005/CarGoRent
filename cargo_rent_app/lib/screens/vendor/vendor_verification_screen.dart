import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../services/api_service.dart';

class VendorVerificationScreen extends StatefulWidget {
  const VendorVerificationScreen({super.key});

  @override
  State<VendorVerificationScreen> createState() =>
      _VendorVerificationScreenState();
}

class _VendorVerificationScreenState
    extends State<VendorVerificationScreen> {
  final _apiService = ApiService();
  final _licenseController = TextEditingController();
  final _idProofController = TextEditingController();
  bool _isLoading = false;
  bool _submitted = false;

  final Color primaryBlue = const Color(0xFF0052CC);
  final Color accentGold = const Color(0xFFFFD700);
  final Color navyDark = const Color(0xFF0F172A);

  @override
  void dispose() {
    _licenseController.dispose();
    _idProofController.dispose();
    super.dispose();
  }

  void _submitDocs() async {
    if (_licenseController.text.trim().isEmpty ||
        _idProofController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields."),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await _apiService.submitVendorDocs(
      _licenseController.text.trim(),
      _idProofController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      setState(() => _submitted = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Submission failed. Please try again."),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: navyDark,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Vendor Verification",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18)),
        elevation: 0,
      ),
      body: _submitted ? _buildSuccessView() : _buildFormView(),
    );
  }

  // ── Success State ─────────────────────────────────────────────────

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green.shade200, width: 2),
              ),
              child: const Icon(Icons.check_circle_outline,
                  color: Colors.green, size: 56),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            const Text("Submitted Successfully!",
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w900))
                .animate()
                .fadeIn(delay: 300.ms),
            const SizedBox(height: 12),
            Text(
              "Your documents have been sent to the Admin for review.\nYou'll have full access once verified.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.5),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: navyDark,
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text("Back to Dashboard",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w900)),
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }

  // ── Form View ─────────────────────────────────────────────────────

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header card ────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [navyDark, primaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: accentGold.withOpacity(0.4)),
                  ),
                  child: Icon(Icons.verified_outlined,
                      color: accentGold, size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Complete Verification",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16)),
                      SizedBox(height: 4),
                      Text(
                          "Submit documents to list cars & accept bookings.",
                          style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),

          const SizedBox(height: 28),

          // ── Steps ───────────────────────────────────────────────
          _buildStepIndicator(),

          const SizedBox(height: 28),

          // ── Form Fields ─────────────────────────────────────────
          Text("Business License",
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: navyDark))
              .animate()
              .fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          _buildField(
            controller: _licenseController,
            hint: "e.g. MH-BL-2024-001234",
            icon: Icons.description_outlined,
            delay: 250,
          ),

          const SizedBox(height: 20),

          Text("ID Proof Document URL",
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: navyDark))
              .animate()
              .fadeIn(delay: 300.ms),
          const SizedBox(height: 4),
          Text("Link to your Aadhar / PAN / Passport scan",
                  style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 12))
              .animate()
              .fadeIn(delay: 320.ms),
          const SizedBox(height: 8),
          _buildField(
            controller: _idProofController,
            hint: "https://drive.google.com/your-document",
            icon: Icons.link_outlined,
            delay: 350,
          ),

          const SizedBox(height: 12),

          // Info note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline,
                    color: primaryBlue, size: 18),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "Your documents are reviewed within 24 hours. You'll be notified once approved.",
                    style: TextStyle(fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitDocs,
              style: ElevatedButton.styleFrom(
                backgroundColor: navyDark,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : const Text("Submit for Approval",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15)),
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required int delay,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: Icon(icon, size: 20, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
            vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: primaryBlue, width: 1.5)),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.2);
  }

  Widget _buildStepIndicator() {
    final steps = [
      "Fill details",
      "Admin review",
      "Get verified",
    ];
    return Row(
      children: steps.asMap().entries.map((e) {
        final isLast = e.key == steps.length - 1;
        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: e.key == 0 ? navyDark : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: e.key == 0
                          ? const Icon(Icons.edit,
                              color: Colors.white, size: 14)
                          : Text("${e.key + 1}",
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(e.value,
                      style: TextStyle(
                          fontSize: 10,
                          color: e.key == 0
                              ? navyDark
                              : Colors.grey.shade400,
                          fontWeight: e.key == 0
                              ? FontWeight.w700
                              : FontWeight.normal)),
                ],
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                      height: 1,
                      margin: const EdgeInsets.only(bottom: 18),
                      color: Colors.grey.shade300),
                ),
            ],
          ),
        );
      }).toList(),
    ).animate().fadeIn(delay: 150.ms);
  }
}