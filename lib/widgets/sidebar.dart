import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final Function(int) onSelect;

  const Sidebar({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.blueGrey[900],
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text("Bug Tracker", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 20),
          ListTile(
            title: const Text("Issues", style: TextStyle(color: Colors.white)),
            onTap: () => onSelect(0),
          ),
          ListTile(
            title: const Text("Create Issue", style: TextStyle(color: Colors.white)),
            onTap: () => onSelect(1),
          ),
        ],
      ),
    );
  }
}