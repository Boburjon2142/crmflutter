import 'package:flutter/material.dart';

import '../authors/authors_list_screen.dart';
import '../catalog/categories_screen.dart';
import '../home/home_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeScreen(),
          CategoriesScreen(),
          AuthorsListScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Asosiy',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            label: 'Kategoriya',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            label: 'Mualliflar',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
