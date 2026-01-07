// lib/providers/menu_provider.dart
import 'package:flutter/material.dart';  // DODAJ
import 'package:flutter/foundation.dart';
import '../models/menu_item_model.dart';

class MenuProvider with ChangeNotifier {
  bool _isMenuOpen = false;
  String _currentPage = 'get_started'; // Aktualna strona
  List<MenuItem> _allMenuItems = []; // Wszystkie możliwe opcje

  bool get isMenuOpen => _isMenuOpen;
  String get currentPage => _currentPage;
  
  // Filtrowane opcje dla aktualnej strony
  List<MenuItem> get currentPageMenuItems {
    return _allMenuItems.where((item) {
      // Jeśli item nie ma pageFilter, pokazuj wszędzie
      if (item.pageFilter == null) return true;
      // Pokazuj tylko jeśli pasuje do aktualnej strony
      return item.pageFilter == _currentPage;
    }).toList();
  }

  MenuProvider() {
    // Inicjalizuj wszystkie możliwe opcje menu
    _initializeMenuItems();
  }

  void _initializeMenuItems() {
    _allMenuItems = [
      // Opcje dla GET_STARTED
      MenuItem(
        title: 'Welcome Page',
        icon: Icons.home,
        route: '/welcome',
        pageFilter: 'get_started',
      ),
      MenuItem(
        title: 'Settings',
        icon: Icons.settings,
        route: '/settings',
        pageFilter: 'get_started',
      ),
      MenuItem(
        title: 'Profile',
        icon: Icons.person,
        route: '/profile',
        pageFilter: 'get_started',
      ),

      // Opcje dla AB_CD (przyszła strona)
      MenuItem(
        title: 'Dashboard',
        icon: Icons.dashboard,
        route: '/dashboard',
        pageFilter: 'ab_cd',
      ),
      MenuItem(
        title: 'Reports',
        icon: Icons.assessment,
        route: '/reports',
        pageFilter: 'ab_cd',
      ),
      MenuItem(
        title: 'Analytics',
        icon: Icons.analytics,
        route: '/analytics',
        pageFilter: 'ab_cd',
      ),

      // Opcje dla WSZYSTKICH stron
      MenuItem(
        title: 'Help',
        icon: Icons.help,
        route: '/help',
        pageFilter: null, // null = pokazuj wszędzie
      ),
      MenuItem(
        title: 'About',
        icon: Icons.info,
        route: '/about',
        pageFilter: null,
      ),
    ];
  }

  void toggleMenu() {
    _isMenuOpen = !_isMenuOpen;
    notifyListeners();
  }

  void closeMenu() {
    _isMenuOpen = false;
    notifyListeners();
  }

  void setCurrentPage(String pageName) {
    _currentPage = pageName;
    notifyListeners();
  }

  // Dodaj nową opcję menu (można użyć w dowolnym miejscu)
  void addMenuItem(MenuItem item) {
    _allMenuItems.add(item);
    notifyListeners();
  }
}