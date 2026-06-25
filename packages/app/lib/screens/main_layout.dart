import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'review_screen.dart';
import 'mocks_screen.dart';
import 'content_browser_screen.dart';
import '../theme/tokens.dart';

/// Bottom-nav shell — ink (#1A1A1A) bar with white icons and a sage active dot.
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  static const _screens = [
    HomeScreen(),
    ContentBrowserScreen(),
    ReviewScreen(),
    MocksScreen(),
  ];

  static const _items = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book_rounded, label: 'Browse'),
    _NavItem(icon: Icons.psychology_outlined, activeIcon: Icons.psychology_rounded, label: 'Review'),
    _NavItem(icon: Icons.assignment_outlined, activeIcon: Icons.assignment_rounded, label: 'Mocks'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: _InkNavBar(
        selectedIndex: _selectedIndex,
        items: _items,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

// ─── Custom dark nav bar ──────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}

class _InkNavBar extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _InkNavBar({
    required this.selectedIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Container(
      color: t.bgBase, // base colour visible at very edge
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final active = i == selectedIndex;
            final item = items[i];
            return GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      active ? item.activeIcon : item.icon,
                      color: active ? Colors.white : Colors.white54,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        color: active ? Colors.white : Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Active dot
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: active ? 16 : 0,
                      height: 3,
                      decoration: BoxDecoration(
                        color: t.sage,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
