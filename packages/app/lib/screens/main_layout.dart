import 'package:flutter/material.dart';
import 'package:store/store.dart';
import 'package:srs/srs.dart';
import 'package:domain/domain.dart';
import 'home_screen.dart';
import 'review_screen.dart';
import 'mocks_screen.dart';
import '../theme/tokens.dart';
import '../services/notification_service.dart';

class MainLayout extends StatefulWidget {
  final DateTime examDate;
  final String examName;
  final ContentStore contentStore;
  final EventLogStore eventStore;
  final SrsStateStore stateStore;
  final Scheduler scheduler;
  final String userId;
  final ExamConfig examConfig;
  final NotificationService notificationService;

  const MainLayout({
    super.key,
    required this.examDate,
    required this.examName,
    required this.contentStore,
    required this.eventStore,
    required this.stateStore,
    required this.scheduler,
    required this.userId,
    required this.examConfig,
    required this.notificationService,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(
        examDate: widget.examDate,
        examName: widget.examName,
        contentStore: widget.contentStore,
        eventStore: widget.eventStore,
        stateStore: widget.stateStore,
        scheduler: widget.scheduler,
        userId: widget.userId,
        notificationService: widget.notificationService,
      ),
      ReviewScreen(
        userId: widget.userId,
        examContext: widget.examName,
        contentStore: widget.contentStore,
        eventStore: widget.eventStore,
        stateStore: widget.stateStore,
        scheduler: widget.scheduler,
      ),
      MocksScreen(
        contentStore: widget.contentStore,
        eventStore: widget.eventStore,
        stateStore: widget.stateStore,
        scheduler: widget.scheduler,
        userId: widget.userId,
        examName: widget.examName,
        examConfig: widget.examConfig,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Scaffold(
      backgroundColor: t.bgBase,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: t.border,
              width: 1.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: t.bgSurface,
          selectedItemColor: t.accent,
          unselectedItemColor: t.textSecondary,
          selectedLabelStyle: AppTypography.micro(t).copyWith(fontWeight: FontWeight.w500),
          unselectedLabelStyle: AppTypography.micro(t),
          type: BottomNavigationBarType.fixed,
          elevation: 0, // no shadow
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.psychology_outlined),
              activeIcon: Icon(Icons.psychology),
              label: 'Review',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Mocks',
            ),
          ],
        ),
      ),
    );
  }
}

