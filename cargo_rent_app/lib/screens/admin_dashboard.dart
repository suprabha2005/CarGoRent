import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import this
import '../services/api_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic> _stats = {};
  List<dynamic> _pendingVendors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    final stats = await _apiService.fetchAdminStats();
    final vendors = await _apiService.fetchPendingVendors();
    setState(() {
      _stats = stats;
      _pendingVendors = vendors;
      _isLoading = false;
    });
  }

  // FIXED: ID Proof Opener
  Future<void> _openLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open ID proof link")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        backgroundColor: Colors.red[900],
        foregroundColor: Colors.white,
        actions: [
          // ADDED: Logout Button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _apiService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Pending Vendor Approvals", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _pendingVendors.length,
                  itemBuilder: (context, i) {
                    final vendor = _pendingVendors[i];
                    return Card(
                      child: ListTile(
                        title: Text(vendor['name']),
                        subtitle: Text(vendor['email']),
                        trailing: Wrap(
                          children: [
                            // FIXED: Link button
                            IconButton(
                              icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                              onPressed: () => _openLink(vendor['idProofUrl'] ?? ""),
                            ),
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              onPressed: () async {
                                await _apiService.approveVendor(vendor['_id']);
                                _loadAdminData();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }
}