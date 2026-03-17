import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ApiService _apiService = ApiService();

  Map<String, dynamic> _stats = {};
  List<dynamic> _pendingVendors = [];
  List<dynamic> _allCars = [];
  List<dynamic> _allBookings = [];
  bool _isLoading = true;
  int _selectedTab = 0; // 0=Overview 1=Vendors 2=Cars 3=Bookings

  // Brand Colors
  final Color navy = const Color(0xFF0F172A);
  final Color red = const Color(0xFFDC2626);
  final Color gold = const Color(0xFFFFD700);
  final Color blue = const Color(0xFF0052CC);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final token = await _apiService.getToken();
      final headers = {"Authorization": "Bearer " + (token ?? "")};
      const base = "http://localhost:5000/api";

      final results = await Future.wait([
        _apiService.fetchAdminStats(),
        _apiService.fetchPendingVendors(),
        http.get(Uri.parse("$base/cars"), headers: headers),
        http.get(Uri.parse("$base/bookings/all-bookings"), headers: headers),
      ]);

      if (mounted) {
        setState(() {
          _stats = results[0] as Map<String, dynamic>;
          _pendingVendors = results[1] as List<dynamic>;
          final carsRes = results[2] as http.Response;
          _allCars = carsRes.statusCode == 200 ? jsonDecode(carsRes.body) : [];
          final bookingsRes = results[3] as http.Response;
          _allBookings = bookingsRes.statusCode == 200 ? jsonDecode(bookingsRes.body) : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _approveVendor(String id) async {
    final ok = await _apiService.approveVendor(id);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("✅ Vendor approved! They can now access their dashboard."),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ));
      await _load(); // ✅ force full reload to remove from pending list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("❌ Approval failed. Check server logs."),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _declineVendor(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Decline Vendor", style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text("Are you sure you want to decline $name's application?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, elevation: 0),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Decline", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    try {
      final token = await _apiService.getToken();
      await http.post(
        Uri.parse("http://localhost:5000/api/admin/decline-vendor"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer " + (token ?? ""),
        },
        body: jsonEncode({"userId": id}),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("❌ Vendor application declined."),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ));
        _load();
      }
    } catch (_) {}
  }

  Future<void> _deleteCar(String carId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Car", style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text("This will permanently remove this car from the platform."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, elevation: 0),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    try {
      final token = await _apiService.getToken();
      final res = await http.delete(
        Uri.parse("http://localhost:5000/api/cars/$carId"),
        headers: {"Authorization": "Bearer " + (token ?? "")},
      );
      if (mounted) {
        if (res.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("🗑️ Car deleted successfully."),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ));
          _load();
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: gold))
          : Column(
              children: [
                _buildTopBar(),
                _buildTabBar(),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: _buildContent(),
                  ),
                ),
              ],
            ),
    );
  }

  // ── Top Bar ──────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 12, 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: red, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Admin Panel",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                Text("CarGoRent Control Center",
                    style: TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white54, size: 22),
              onPressed: _load,
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent, size: 22),
              onPressed: () async {
                await _apiService.logout();
                if (mounted) Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab Bar ──────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    final tabs = [
      (Icons.dashboard_outlined, "Overview"),
      (Icons.people_outline, "Vendors ${_pendingVendors.isNotEmpty ? '(${_pendingVendors.length})' : ''}"),
      (Icons.directions_car_outlined, "Cars"),
      (Icons.book_outlined, "Bookings"),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.asMap().entries.map((e) {
            final isActive = _selectedTab == e.key;
            final hasAlert = e.key == 1 && _pendingVendors.isNotEmpty;
            return GestureDetector(
              onTap: () => setState(() => _selectedTab = e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: isActive ? gold : Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? gold : (hasAlert ? Colors.orange.withOpacity(0.5) : Colors.white.withOpacity(0.1)),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(e.value.$1, size: 15, color: isActive ? navy : Colors.white54),
                    const SizedBox(width: 6),
                    Text(e.value.$2,
                        style: TextStyle(
                            color: isActive ? navy : Colors.white54,
                            fontWeight: FontWeight.w800,
                            fontSize: 12)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Content Router ───────────────────────────────────────────────────

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0: return _buildOverview();
      case 1: return _buildVendorsTab();
      case 2: return _buildCarsTab();
      case 3: return _buildBookingsTab();
      default: return _buildOverview();
    }
  }

  // ── Overview Tab ─────────────────────────────────────────────────────

  Widget _buildOverview() {
    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Text("Platform Overview",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: navy))
                    .animate().fadeIn(duration: 400.ms),
                const Spacer(),
                Text("Last updated just now",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
              ],
            ),
            const SizedBox(height: 16),

            // ── Stats Row — fixed height, no GridView ──────────────
            Row(
              children: [
                _statCard(Icons.people_outline, "${_stats['totalUsers'] ?? 0}", "Total Users", Colors.blue, 0),
                const SizedBox(width: 12),
                _statCard(Icons.directions_car_outlined, "${_stats['totalCars'] ?? 0}", "Cars Listed", Colors.green, 1),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _statCard(Icons.pending_outlined, "${_stats['pendingVendors'] ?? 0}", "Pending Vendors",
                    (_stats['pendingVendors'] ?? 0) > 0 ? Colors.orange : Colors.grey, 2),
                const SizedBox(width: 12),
                _statCard(Icons.currency_rupee, "₹${_stats['totalRevenue'] ?? 0}", "Total Revenue", gold, 3),
              ],
            ),

            // ── Pending Vendors Alert ──────────────────────────────
            if (_pendingVendors.isNotEmpty) ...[
              const SizedBox(height: 28),
              _overviewSectionHeader(
                "⚡ Pending Approvals",
                "${_pendingVendors.length} vendors waiting",
                Colors.orange,
                onTap: () => setState(() => _selectedTab = 1),
              ),
              const SizedBox(height: 12),
              ..._pendingVendors.take(2).map((v) => _buildCompactVendorCard(v)),
            ],

            // ── Recent Cars ────────────────────────────────────────
            if (_allCars.isNotEmpty) ...[
              const SizedBox(height: 28),
              _overviewSectionHeader(
                "🚗 Recent Cars",
                "${_allCars.length} total",
                Colors.green,
                onTap: () => setState(() => _selectedTab = 2),
              ),
              const SizedBox(height: 12),
              ..._allCars.take(3).map((c) => _buildOverviewCarRow(c)),
            ],

            // ── Recent Bookings ────────────────────────────────────
            if (_allBookings.isNotEmpty) ...[
              const SizedBox(height: 28),
              _overviewSectionHeader(
                "📋 Recent Bookings",
                "${_allBookings.length} total",
                blue,
                onTap: () => setState(() => _selectedTab = 3),
              ),
              const SizedBox(height: 12),
              ..._allBookings.take(3).map((b) => _buildBookingCard(b, 0)),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _overviewSectionHeader(String title, String subtitle, Color color, {required VoidCallback onTap}) {
    return Row(
      children: [
        Container(width: 4, height: 18, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: navy)),
        const SizedBox(width: 8),
        Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        const Spacer(),
        GestureDetector(
          onTap: onTap,
          child: Text("View all →", style: TextStyle(color: blue, fontWeight: FontWeight.w700, fontSize: 12)),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildOverviewCarRow(dynamic car) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 40,
            decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(8)),
            child: Image.network(car['imageUrl'] ?? '', fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(Icons.directions_car, color: Colors.grey.shade400, size: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${car['brand']} ${car['name']}", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                Text("${car['type']}  ·  ₹${car['pricePerDay']}/day", style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (car['isAvailable'] ?? true) ? Colors.green.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              (car['isAvailable'] ?? true) ? "Active" : "Rented",
              style: TextStyle(
                  color: (car['isAvailable'] ?? true) ? Colors.green : Colors.orange,
                  fontSize: 11, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String value, String label, Color color, int index) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: navy)),
                Text(label,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: 100 + index * 80)).slideY(begin: 0.15),
    );
  }

  Widget _buildCompactVendorCard(dynamic vendor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: navy.withOpacity(0.1),
            child: Text((vendor['name'] ?? '?')[0].toUpperCase(),
                style: TextStyle(color: navy, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vendor['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                Text(vendor['email'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _approveVendor(vendor['_id']),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
              child: const Text("Approve", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Vendors Tab ──────────────────────────────────────────────────────

  Widget _buildVendorsTab() {
    return _pendingVendors.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text("All caught up!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.grey)),
                const Text("No pending vendor approvals.", style: TextStyle(color: Colors.grey)),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pendingVendors.length,
              itemBuilder: (ctx, i) => _buildVendorCard(_pendingVendors[i], i),
            ),
          );
  }

  Widget _buildVendorCard(dynamic vendor, int index) {
    final hasLicense = (vendor['businessLicense'] ?? '').toString().isNotEmpty;
    final hasIdProof = (vendor['idProofUrl'] ?? '').toString().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.shade200, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: navy.withOpacity(0.08),
                  child: Text(
                    (vendor['name'] ?? '?')[0].toUpperCase(),
                    style: TextStyle(color: navy, fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vendor['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      Text(vendor['email'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Text("PENDING",
                      style: TextStyle(color: Colors.orange.shade700, fontSize: 10, fontWeight: FontWeight.w900)),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),

            // Documents
            Row(
              children: [
                _docChip(Icons.description_outlined, "License", hasLicense, vendor['businessLicense']),
                const SizedBox(width: 10),
                _docChip(Icons.link_outlined, "ID Proof", hasIdProof, vendor['idProofUrl']),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                // DECLINE
                Expanded(
                  child: GestureDetector(
                    onTap: () => _declineVendor(vendor['_id'], vendor['name'] ?? ''),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close, color: Colors.redAccent, size: 17),
                          SizedBox(width: 6),
                          Text("DECLINE", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // APPROVE
                Expanded(
                  child: GestureDetector(
                    onTap: () => _approveVendor(vendor['_id']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, color: Colors.white, size: 17),
                          SizedBox(width: 6),
                          Text("APPROVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 60 + index * 80)).slideY(begin: 0.15);
  }

  Widget _docChip(IconData icon, String label, bool hasValue, String? value) {
    return Expanded(
      child: GestureDetector(
        onTap: hasValue && value != null
            ? () async {
                try {
                  // just show it in a dialog since url_launcher may not be available
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(label),
                      content: SelectableText(value),
                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
                    ),
                  );
                } catch (_) {}
              }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: hasValue ? Colors.blue.shade50 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: hasValue ? Colors.blue.shade200 : Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(icon, size: 15, color: hasValue ? blue : Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  hasValue ? label + " ↗" : "No $label",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: hasValue ? blue : Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Cars Tab ─────────────────────────────────────────────────────────

  Widget _buildCarsTab() {
    if (_allCars.isEmpty) {
      return const Center(child: Text("No cars found.", style: TextStyle(color: Colors.grey)));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allCars.length,
        itemBuilder: (ctx, i) => _buildAdminCarCard(_allCars[i], i),
      ),
    );
  }

  Widget _buildAdminCarCard(dynamic car, int index) {
    final isAvailable = car['isAvailable'] ?? true;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 90,
              height: 80,
              color: const Color(0xFFF0F4FF),
              padding: const EdgeInsets.all(8),
              child: Image.network(
                car['imageUrl'] ?? '',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(Icons.directions_car, size: 32, color: Colors.grey.shade400),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text("${car['brand']} ${car['name']}",
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isAvailable ? Colors.green.shade50 : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isAvailable ? "Active" : "Rented",
                            style: TextStyle(
                                color: isAvailable ? Colors.green : Colors.orange,
                                fontSize: 10, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text("${car['type']}  ·  ₹${car['pricePerDay']}/day",
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          "Vendor: ${car['vendorId'] is Map ? car['vendorId']['name'] ?? 'Unknown' : 'Unknown'}",
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _deleteCar(car['_id']),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.delete_outline, size: 13, color: Colors.redAccent),
                                const SizedBox(width: 4),
                                const Text("Remove", style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 60 + index * 60)).slideY(begin: 0.15);
  }

  // ── Bookings Tab ─────────────────────────────────────────────────────

  Widget _buildBookingsTab() {
    if (_allBookings.isEmpty) {
      return const Center(child: Text("No bookings found.", style: TextStyle(color: Colors.grey)));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allBookings.length,
        itemBuilder: (ctx, i) => _buildBookingCard(_allBookings[i], i),
      ),
    );
  }

  Widget _buildBookingCard(dynamic booking, int index) {
    final status = (booking['status'] ?? 'pending') as String;
    final carName = booking['carId'] is Map ? booking['carId']['name'] ?? 'Car' : 'Car';
    final customerName = booking['customerId'] is Map ? booking['customerId']['name'] ?? 'Customer' : 'Customer';
    final total = (booking['totalPrice'] as num?)?.toDouble() ?? 0;

    Color statusColor;
    switch (status) {
      case 'confirmed': statusColor = Colors.green; break;
      case 'cancelled': statusColor = Colors.redAccent; break;
      case 'completed': statusColor = Colors.blue; break;
      default: statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.directions_car_outlined, color: statusColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(carName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                Text("Customer: $customerName", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 4),
              Text("₹${total.toStringAsFixed(0)}",
                  style: TextStyle(color: blue, fontWeight: FontWeight.w900, fontSize: 14)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 40 + index * 50)).slideY(begin: 0.1);
  }
}