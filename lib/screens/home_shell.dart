import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/app_header.dart';
import '../widgets/app_sidebar.dart';
import 'dashboard_screen.dart';
import 'issues_screen.dart';

class HomeShell extends StatefulWidget {
  final VoidCallback onLogout;

  const HomeShell({super.key, required this.onLogout});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _authService = AuthService();

  int _selectedIndex = 0;
  String _userEmail = 'User';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final email = await _authService.getEmail();
    if (!mounted) return;
    setState(() {
      _userEmail = email;
    });
  }

  Future<void> _logout() async {
    await _authService.logout();
    widget.onLogout();
  }

  String get _title {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Issues';
      case 2:
        return 'Projects';
      case 3:
        return 'Users';
      case 4:
        return 'Settings';
      default:
        return 'Dashboard';
    }
  }

  String get _subtitle {
    switch (_selectedIndex) {
      case 0:
        return 'Overview of issue health, team progress, and current workload';
      case 1:
        return 'Manage and monitor all reported bugs and development issues';
      case 2:
        return 'Track project-level issue distribution and ownership';
      case 3:
        return 'Manage team access and responsibilities';
      case 4:
        return 'System preferences and configuration';
      default:
        return '';
    }
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const IssuesScreen();
      case 2:
        return const _PlaceholderPage(title: 'Projects module coming next');
      case 3:
        return const _PlaceholderPage(title: 'Users module coming next');
      case 4:
        return const _PlaceholderPage(title: 'Settings module coming next');
      default:
        return const DashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            selectedIndex: _selectedIndex,
            onSelect: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            onLogout: _logout,
          ),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: _title,
                  subtitle: _subtitle,
                  userEmail: _userEmail,
                ),
                Expanded(child: _buildPage()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}