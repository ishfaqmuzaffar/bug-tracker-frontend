import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final items = const [
      _SidebarItemData('Dashboard', Icons.dashboard_rounded),
      _SidebarItemData('Issues', Icons.bug_report_rounded),
      _SidebarItemData('Projects', Icons.folder_rounded),
      _SidebarItemData('Users', Icons.people_alt_rounded),
      _SidebarItemData('Settings', Icons.settings_rounded),
    ];

    return Container(
      width: 260,
      color: AppColors.sidebar,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BrandBlock(),
              const SizedBox(height: 24),
              ...List.generate(
                items.length,
                (index) => _SidebarTile(
                  title: items[index].title,
                  icon: items[index].icon,
                  selected: selectedIndex == index,
                  onTap: () => onSelect(index),
                ),
              ),
              const Spacer(),
              const Divider(color: Color(0xFF334155)),
              const SizedBox(height: 12),
              _SidebarTile(
                title: 'Logout',
                icon: Icons.logout_rounded,
                selected: false,
                onTap: onLogout,
                danger: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.bug_report_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bug Tracker',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Internal System',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool danger;

  const _SidebarTile({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? AppColors.primary.withOpacity(0.18)
        : Colors.transparent;

    final textColor = danger
        ? const Color(0xFFFCA5A5)
        : selected
            ? Colors.white
            : const Color(0xFFCBD5E1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarItemData {
  final String title;
  final IconData icon;

  const _SidebarItemData(this.title, this.icon);
}