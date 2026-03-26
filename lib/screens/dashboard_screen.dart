import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';
import 'issues_screen.dart';
import 'create_issue_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget screen;

    if (selectedIndex == 0) {
      screen = const IssuesScreen();
    } else {
      screen = const CreateIssueScreen();
    }

    return Scaffold(
      body: Row(
        children: [
          Sidebar(onSelect: (i) => setState(() => selectedIndex = i)),
          Expanded(
            child: Column(
              children: [
                const Topbar(),
                Expanded(child: screen),
              ],
            ),
          ),
        ],
      ),
    );
  }
}