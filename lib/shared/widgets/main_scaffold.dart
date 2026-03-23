import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final _navItems = [
    const _NavItem(icon: Icons.home_rounded, label: 'Home', path: '/home'),
    const _NavItem(icon: Icons.checkroom_rounded, label: 'Builder', path: '/outfit-builder'),
    const _NavItem(icon: Icons.style_rounded, label: 'Swipe', path: '/swipe-outfits'),
    const _NavItem(icon: Icons.person_rounded, label: 'Profile', path: '/profile'),
  ];

  void _onTap(int index) {
    setState(() => _selectedIndex = index);
    context.go(_navItems[index].path);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: widget.child,
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/add-item'),
            tooltip: 'Add Clothing',
            child: const Icon(Icons.add_rounded, size: 28),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: _BottomNav(
            selectedIndex: _selectedIndex,
            onTap: _onTap,
            items: _navItems,
          ),
        ),
        // Persistent Global Logo
        Positioned(
          top: 60,
          right: 30,
          child: Image.asset(
            "assets/icons/Dressify_withName.png",
            width: 50,
            height: 50,
            fit: BoxFit.contain,
          ).animate().fadeIn(duration: 800.ms),
        ),
      ],
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String path;
  const _NavItem({required this.icon, required this.label, required this.path});
}

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<_NavItem> items;

  const _BottomNav({
    required this.selectedIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i == 2) const SizedBox(width: 56), // FAB space
                _NavBtn(
                  item: items[i],
                  isSelected: selectedIndex == i,
                  onTap: () => onTap(i),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBtn({required this.item, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isSelected ? AppTheme.primary : AppTheme.textHint,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppTheme.primary : AppTheme.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
