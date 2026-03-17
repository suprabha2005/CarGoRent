import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import '../../../services/api_service.dart';

class VendorPendingScreen extends StatefulWidget {
  const VendorPendingScreen({super.key});

  @override
  State<VendorPendingScreen> createState() => _VendorPendingScreenState();
}

class _VendorPendingScreenState extends State<VendorPendingScreen> {
  final ApiService _apiService = ApiService();
  bool _isChecking = false;

  final Color navy = const Color(0xFF0F172A);
  final Color gold = const Color(0xFFFFD700);

  Future<void> _checkStatus() async {
    setState(() => _isChecking = true);

    try {
      final token = await _apiService.getToken();
      final res = await http.get(
        Uri.parse("http://localhost:5000/api/auth/profile"),
        headers: {"Authorization": "Bearer " + (token ?? "")},
      );

      setState(() => _isChecking = false);
      if (!mounted) return;

      if (res.statusCode == 200) {
        final profile = jsonDecode(res.body);
        final status = profile['verificationStatus'] ?? 'pending';

        if (status == 'approved') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("🎉 Approved! Welcome to your Vendor Dashboard."),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pushReplacementNamed(context, '/vendor_dashboard');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("⏳ Still under review. Please check back later."),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isChecking = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not check status. Try again."),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Top bar ───────────────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    await _apiService.logout();
                    if (mounted) Navigator.pushReplacementNamed(context, '/login');
                  },
                  icon: const Icon(Icons.logout, color: Colors.white54, size: 18),
                  label: const Text("Logout", style: TextStyle(color: Colors.white54, fontSize: 13)),
                ),
              ),

              const SizedBox(height: 32),

              // ── Animated hourglass ─────────────────────────────────
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: gold.withOpacity(0.3), width: 2),
                ),
                child: Icon(Icons.hourglass_top_rounded, color: gold, size: 52),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 2000.ms, color: gold.withOpacity(0.3))
                  .animate()
                  .scale(begin: const Offset(0.8, 0.8), duration: 600.ms, curve: Curves.elasticOut),

              const SizedBox(height: 28),

              const Text("Pending Approval",
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900))
                  .animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

              const SizedBox(height: 12),

              const Text(
                "Your account is under review by our admin team. You will get full dashboard access once approved.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.6),
              ),

              const SizedBox(height: 36),

              // ── Progress steps ──────────────────────────────────────
              _buildStep("1", "Documents submitted", done: true, delay: 380),
              const SizedBox(height: 12),
              _buildStep("2", "Admin review in progress", done: true, inProgress: true, delay: 460),
              const SizedBox(height: 12),
              _buildStep("3", "Dashboard access granted", done: false, delay: 540),

              const SizedBox(height: 40),

              // ── Check status button ─────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : _checkStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isChecking
                      ? SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(color: navy, strokeWidth: 2.5))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh, color: navy, size: 20),
                            const SizedBox(width: 8),
                            Text("Check Approval Status",
                                style: TextStyle(color: navy, fontWeight: FontWeight.w900, fontSize: 15)),
                          ],
                        ),
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),

              const SizedBox(height: 14),

              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/vendor_verification'),
                child: const Text("Haven't submitted documents yet? →",
                    style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w600)),
              ).animate().fadeIn(delay: 700.ms),

              const SizedBox(height: 32),

              const Text("© 2026 CarGoRent India",
                  style: TextStyle(color: Colors.white24, fontSize: 11)),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String number, String label,
      {required bool done,
      bool inProgress = false,
      required int delay}) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: done
                ? (inProgress
                    ? Colors.orange.withOpacity(0.2)
                    : gold)
                : Colors.white.withOpacity(0.06),
            shape: BoxShape.circle,
            border: Border.all(
              color: done
                  ? (inProgress ? Colors.orange : gold)
                  : Colors.white24,
              width: 1.5,
            ),
          ),
          child: Center(
            child: done
                ? Icon(
                    inProgress ? Icons.sync : Icons.check,
                    color: inProgress ? Colors.orange : navy,
                    size: 16,
                  )
                : Text(number,
                    style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          label,
          style: TextStyle(
            color: done
                ? (inProgress ? Colors.orange : Colors.white)
                : Colors.white38,
            fontSize: 14,
            fontWeight: done ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        if (inProgress) ...[
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: const Text("IN PROGRESS",
                style: TextStyle(
                    color: Colors.orange,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5)),
          ),
        ]
      ],
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: -0.2);
  }
}