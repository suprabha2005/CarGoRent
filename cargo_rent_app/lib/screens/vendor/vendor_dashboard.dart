import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../models/car_model.dart';
import 'add_car_screen.dart';
import 'vendor_verification_screen.dart';

class VendorDashboard extends StatefulWidget {
  const VendorDashboard({super.key});

  @override
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  final ApiService _apiService = ApiService();
  List<Car> _myCars = [];
  List<dynamic> _requests = [];
  bool _isLoading = true;
  int _selectedTab = 0; // 0 = Fleet, 1 = Requests

  final Color gold = const Color(0xFFFFD700);
  final Color navy = const Color(0xFF0F172A);
  final Color blue = const Color(0xFF0052CC);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final userId = await _apiService.getUserId();
    if (userId != null) {
      final results = await Future.wait([
        _apiService.fetchVendorCars(userId),
        _apiService.fetchVendorRequests(),
      ]);
      if (mounted) {
        setState(() {
          _myCars = results[0] as List<Car>;
          _requests = results[1] as List<dynamic>;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String bookingId, String status) async {
    final ok = await _apiService.updateBookingStatus(bookingId, status);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(status == 'confirmed'
            ? '✅ Booking accepted!'
            : '❌ Booking rejected.'),
        backgroundColor:
            status == 'confirmed' ? Colors.green : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
      _load();
    }
  }

  int get _pendingCount =>
      _requests.where((r) => r['status'] == 'pending').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // dark bg
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: gold))
          : Column(
              children: [
                _buildTopBar(),
                _buildStatsRow(),
                _buildTabSwitcher(),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: _selectedTab == 0
                        ? _buildFleetPanel()
                        : _buildRequestsPanel(),
                  ),
                ),
              ],
            ),
    );
  }

  // ── Top Bar ───────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: gold,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.storefront, color: navy, size: 22),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Vendor Panel",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
                Text("Manage your fleet & bookings",
                    style:
                        TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
            const Spacer(),
            // Verification
            IconButton(
              icon: const Icon(Icons.verified_outlined,
                  color: Colors.white54, size: 22),
              tooltip: "Verification",
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const VendorVerificationScreen()),
              ),
            ),
            // Refresh
            IconButton(
              icon: const Icon(Icons.refresh,
                  color: Colors.white54, size: 22),
              onPressed: _load,
            ),
            // Logout
            IconButton(
              icon: const Icon(Icons.logout,
                  color: Colors.redAccent, size: 22),
              onPressed: () async {
                await _apiService.logout();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Stats Row ─────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    final confirmed =
        _requests.where((r) => r['status'] == 'confirmed').length;
    final earnings = _requests
        .where((r) => r['status'] == 'confirmed')
        .fold<double>(
            0, (s, r) => s + ((r['totalPrice'] as num?)?.toDouble() ?? 0));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Row(
        children: [
          _statTile(Icons.directions_car, "${_myCars.length}", "Cars", gold),
          const SizedBox(width: 10),
          _statTile(Icons.pending_actions,
              "$_pendingCount", "Pending",
              _pendingCount > 0 ? Colors.orange : Colors.white24),
          const SizedBox(width: 10),
          _statTile(Icons.check_circle_outline,
              "$confirmed", "Confirmed", Colors.green),
          const SizedBox(width: 10),
          _statTile(Icons.currency_rupee,
              earnings.toStringAsFixed(0), "Earned", Colors.blue.shade300),
        ],
      ),
    );
  }

  Widget _statTile(
      IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16)),
            Text(label,
                style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
    );
  }

  // ── Tab Switcher ──────────────────────────────────────────────────────

  Widget _buildTabSwitcher() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _tabButton(0, Icons.directions_car_outlined, "My Fleet",
                "${_myCars.length}"),
            _tabButton(1, Icons.inbox_outlined, "Requests",
                "$_pendingCount"),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(
      int index, IconData icon, String label, String badge) {
    final isActive = _selectedTab == index;
    final hasBadge = index == 1 && _pendingCount > 0;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? gold : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 17,
                  color: isActive ? navy : Colors.white54),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: isActive ? navy : Colors.white54,
                      fontWeight: FontWeight.w900,
                      fontSize: 13)),
              if (hasBadge) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color:
                        isActive ? navy : Colors.redAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text("$_pendingCount",
                      style: TextStyle(
                          color: isActive
                              ? gold
                              : Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900)),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  // ── Fleet Panel ───────────────────────────────────────────────────────

  Widget _buildFleetPanel() {
    return Column(
      children: [
        // Panel header with Add Car button
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${_myCars.length} cars listed",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: navy),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddCarScreen()),
                ).then((_) => _load()),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: navy,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text("ADD CAR",
                          style: TextStyle(
                              color: gold,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 0.5)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Fleet list
        Expanded(
          child: _myCars.isEmpty
              ? _emptyState(
                  Icons.directions_car_outlined,
                  "No cars listed yet.",
                  "Tap 'ADD CAR' to list your first vehicle.",
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: _myCars.length,
                    itemBuilder: (ctx, i) =>
                        _buildCarRow(_myCars[i], i),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCarRow(Car car, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Row(
          children: [
            // Car image
            Container(
              width: 100,
              height: 90,
              color: const Color(0xFFF0F4FF),
              padding: const EdgeInsets.all(8),
              child: Image.network(
                car.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                    Icons.directions_car,
                    size: 36,
                    color: Colors.grey.shade400),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(car.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: car.isAvailable
                                ? Colors.green.shade50
                                : Colors.orange.shade50,
                            borderRadius:
                                BorderRadius.circular(20),
                            border: Border.all(
                                color: car.isAvailable
                                    ? Colors.green.shade300
                                    : Colors.orange.shade300),
                          ),
                          child: Text(
                            car.isAvailable
                                ? "● Active"
                                : "● Rented",
                            style: TextStyle(
                                color: car.isAvailable
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                                fontSize: 11,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text("${car.brand}  ·  ${car.type}",
                        style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text("₹${car.pricePerDay}/day",
                            style: TextStyle(
                                color: blue,
                                fontWeight: FontWeight.w900,
                                fontSize: 14)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () =>
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                            content: Text("Edit coming soon!"),
                            behavior: SnackBarBehavior.floating,
                          )),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.shade300),
                              borderRadius:
                                  BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined,
                                    size: 13,
                                    color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Text("Edit",
                                    style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            Colors.grey.shade600,
                                        fontWeight:
                                            FontWeight.w700)),
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
    )
        .animate()
        .fadeIn(
            delay: Duration(milliseconds: 60 + index * 80),
            duration: 400.ms)
        .slideY(begin: 0.15, curve: Curves.easeOut);
  }

  // ── Requests Panel ────────────────────────────────────────────────────

  Widget _buildRequestsPanel() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              Text("${_requests.length} total requests",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: navy)),
              if (_pendingCount > 0) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.orange.shade300),
                  ),
                  child: Text("$_pendingCount pending",
                      style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w900,
                          fontSize: 12)),
                ),
              ]
            ],
          ),
        ),
        Expanded(
          child: _requests.isEmpty
              ? _emptyState(
                  Icons.inbox_outlined,
                  "No booking requests yet.",
                  "Customer bookings will appear here.",
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: _requests.length,
                    itemBuilder: (ctx, i) =>
                        _buildRequestCard(_requests[i], i),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(dynamic req, int index) {
    final status = (req['status'] ?? 'pending') as String;
    final carName =
        (req['carId'] is Map ? req['carId']['name'] : null) ??
            'Car';
    final carImage =
        req['carId'] is Map ? req['carId']['imageUrl'] : null;
    final customerName =
        (req['customerId'] is Map
                ? req['customerId']['name']
                : null) ??
            'Customer';
    final customerEmail =
        req['customerId'] is Map
            ? req['customerId']['email'] ?? ''
            : '';
    final total =
        (req['totalPrice'] as num?)?.toDouble() ?? 0;
    final start = req['startDate'] != null
        ? DateTime.tryParse(req['startDate'])
        : null;
    final end = req['endDate'] != null
        ? DateTime.tryParse(req['endDate'])
        : null;
    final days = (start != null && end != null)
        ? end.difference(start).inDays + 1
        : null;

    // Status config
    Color statusBg, statusFg;
    IconData statusIcon;
    switch (status) {
      case 'confirmed':
        statusBg = Colors.green.shade50;
        statusFg = Colors.green.shade700;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'cancelled':
        statusBg = Colors.red.shade50;
        statusFg = Colors.redAccent;
        statusIcon = Icons.cancel_outlined;
        break;
      case 'completed':
        statusBg = Colors.blue.shade50;
        statusFg = Colors.blue;
        statusIcon = Icons.done_all;
        break;
      default: // pending
        statusBg = Colors.orange.shade50;
        statusFg = Colors.orange.shade700;
        statusIcon = Icons.schedule_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: status == 'pending'
              ? Colors.orange.shade200
              : Colors.grey.shade200,
          width: status == 'pending' ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          // ── Top: Car + Status ───────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: navy.withOpacity(0.03),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                // Car thumbnail
                Container(
                  width: 56,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: carImage != null
                      ? Image.network(carImage,
                          fit: BoxFit.contain)
                      : Icon(Icons.directions_car,
                          size: 26,
                          color: Colors.grey.shade400),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(carName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16)),
                      if (days != null)
                        Text("$days day rental",
                            style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color:
                            statusFg.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon,
                          size: 13, color: statusFg),
                      const SizedBox(width: 4),
                      Text(status.toUpperCase(),
                          style: TextStyle(
                              color: statusFg,
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 0.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Middle: Customer + Dates + Price ────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // Customer row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          navy.withOpacity(0.1),
                      child: Text(
                        customerName.isNotEmpty
                            ? customerName[0]
                                .toUpperCase()
                            : "?",
                        style: TextStyle(
                            color: navy,
                            fontWeight: FontWeight.w900,
                            fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(customerName,
                              style: const TextStyle(
                                  fontWeight:
                                      FontWeight.w700,
                                  fontSize: 13)),
                          if (customerEmail.isNotEmpty)
                            Text(customerEmail,
                                style: TextStyle(
                                    color: Colors
                                        .grey.shade500,
                                    fontSize: 11)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.end,
                      children: [
                        Text(
                          "₹${total.toStringAsFixed(0)}",
                          style: TextStyle(
                              color: blue,
                              fontWeight: FontWeight.w900,
                              fontSize: 18),
                        ),
                        const Text("total",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11)),
                      ],
                    ),
                  ],
                ),

                // Dates
                if (start != null && end != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFF8FAFC),
                      borderRadius:
                          BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 14,
                            color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(_formatDate(start),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward,
                            size: 14,
                            color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(_formatDate(end),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                        const Spacer(),
                        if (days != null)
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3),
                            decoration: BoxDecoration(
                              color: navy,
                              borderRadius:
                                  BorderRadius.circular(6),
                            ),
                            child: Text("$days days",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight:
                                        FontWeight.w900)),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Bottom: Action Buttons (only if pending) ────────
          if (status == 'pending')
            Container(
              padding: const EdgeInsets.fromLTRB(
                  14, 0, 14, 14),
              child: Row(
                children: [
                  // REJECT
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _updateStatus(
                          req['_id'], 'cancelled'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 13),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius:
                              BorderRadius.circular(10),
                          border: Border.all(
                              color:
                                  Colors.redAccent
                                      .withOpacity(0.4)),
                        ),
                        child: const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(Icons.close,
                                color: Colors.redAccent,
                                size: 17),
                            SizedBox(width: 6),
                            Text("DECLINE",
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight:
                                        FontWeight.w900,
                                    fontSize: 13,
                                    letterSpacing: 0.5)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // APPROVE
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _updateStatus(
                          req['_id'], 'confirmed'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 13),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check,
                                color: Colors.white,
                                size: 17),
                            SizedBox(width: 6),
                            Text("APPROVE",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.w900,
                                    fontSize: 13,
                                    letterSpacing: 0.5)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    )
        .animate()
        .fadeIn(
            delay: Duration(milliseconds: 60 + index * 80),
            duration: 400.ms)
        .slideY(begin: 0.15, curve: Curves.easeOut);
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  Widget _emptyState(
      IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(title,
              style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(subtitle,
              style: TextStyle(
                  color: Colors.grey.shade400, fontSize: 13)),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return "${d.day} ${months[d.month - 1]}";
  }
}