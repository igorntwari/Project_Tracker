import 'package:flutter/material.dart';

import '../widgets/task_widgets.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'task_list_screen.dart';
import 'team_screen.dart';

// Holds the bottom navigation bar and switches between the main tabs
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const int _profileTab = 3;

  int _currentIndex = 0;

  // Tabs visited before the current one, so back can return to the previous tab
  final List<int> _tabHistory = [];

  void _onTabSelected(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _tabHistory.remove(index); // Avoid loops like Home > Tasks > Home > Tasks
      _tabHistory.add(_currentIndex);
      _currentIndex = index;
    });
  }

  void _goToPreviousTab() {
    if (_tabHistory.isEmpty) return;
    setState(() => _currentIndex = _tabHistory.removeLast());
  }

  @override
  Widget build(BuildContext context) {
    // Tapping the JD avatar in any app bar jumps to the Profile tab
    void openProfile() => _onTabSelected(_profileTab);

    // The phone's back button/gesture goes to the previous tab before closing the app
    return PopScope(
      canPop: _tabHistory.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goToPreviousTab();
      },
      child: Scaffold(
        // IndexedStack keeps each tab's state (scroll position, filters) when switching
        body: IndexedStack(
          index: _currentIndex,
          children: [
            HomeScreen(onAvatarTap: openProfile),
            TaskListScreen(onAvatarTap: openProfile),
            TeamScreen(onAvatarTap: openProfile),
            ProfileScreen(onBack: _goToPreviousTab),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabSelected,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: kPrimaryBlue,
          unselectedItemColor: const Color(0xFF64748B),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_outlined),
              activeIcon: Icon(Icons.groups),
              label: 'Team',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
