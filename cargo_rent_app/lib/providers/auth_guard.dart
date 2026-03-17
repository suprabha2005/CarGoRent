import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../screens/login_screen.dart';

class AuthGuard extends StatefulWidget {
  final Widget child;
  final List<String> allowedRoles; // e.g. ['admin'] or ['vendor'] or ['customer']

  const AuthGuard({
    super.key,
    required this.child,
    required this.allowedRoles,
  });

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  final _api = ApiService();
  bool _checking = true;
  bool _allowed = false;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final token = await _api.getToken();
    final role = await _api.getRole();

    if (token == null || role == null) {
      // Not logged in at all
      setState(() {
        _checking = false;
        _allowed = false;
      });
      return;
    }

    if (widget.allowedRoles.contains(role)) {
      // Logged in AND correct role
      setState(() {
        _checking = false;
        _allowed = true;
      });
    } else {
      // Logged in but wrong role
      setState(() {
        _checking = false;
        _allowed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Still checking token
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Not allowed — redirect to login
    if (!_allowed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Allowed — show the actual screen
    return widget.child;
  }
}