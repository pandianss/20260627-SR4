import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'review_screen.dart';
import 'mocks_screen.dart';
import '../theme/tokens.dart';

/// Bottom-nav shell. Screens are const and read their dependencies from the
/// surrounding AppScope, so this layout forwards nothing.
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  static const _screens = [
    HomeScreen(),
    ReviewScreen(),
    MocksScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Scaffold(
      backgroundColor: t.bgBase,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: t.border, width: 1.0)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: t.bgSurface,
          selectedItemColor: t.accent,
          unselectedItemColor: t.textSecondary,
          selectedLabelStyle:
              AppTypography.micro(t).copyWith(fontWeight: FontWeight.w500),
          unselectedLabelStyle: AppTypography.micro(t),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.psychology_outlined),
                activeIcon: Icon(Icons.psychology),
                label: 'Review'),
            BottomNavigationBarItem(
                icon: Icon(Icons.assignment_outlined),
                activeIcon: Icon(Icons.assignment),
                label: 'Mocks'),
          ],
        ),
      ),
    );
  }
}
