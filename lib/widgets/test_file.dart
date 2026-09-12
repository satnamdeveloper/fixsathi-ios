import 'package:flutter/material.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Tracks the order of tabs visited by the user
  final List<int> _navigationHistory = [0];

  final List<Widget> _pages = [
    const Center(child: Text('Home Screen', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Search Screen', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Profile Screen', style: TextStyle(fontSize: 24))),
  ];

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
      // Remove index if it already exists to avoid redundant loops
      _navigationHistory.remove(index);
      // Push the newest selected tab to the end of the history list
      _navigationHistory.add(index);
    });
  }

  Future<bool> _handleBackPress() async {
    // If the user is not at the home tab or has history, go back through history
    if (_navigationHistory.length > 1) {
      setState(() {
        // Remove the current active tab from history
        _navigationHistory.removeLast();
        // Set the active index to the previous tab in history
        _currentIndex = _navigationHistory.last;
      });
      return false; // Blocks the default application exit behavior
    }

    return true; // Exits the app when no navigation history remains
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop:
          _navigationHistory.length <=
          1, // Only allows OS pop if history is empty
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackPress();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Tab History Navigation')),
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
