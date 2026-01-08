// lib/providers/menu_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/menu_item_model.dart';

class MenuProvider with ChangeNotifier {
  bool _isMenuOpen = false;
  String _currentPage = 'get_started';
  List<MenuItem> _allMenuItems = [];

  bool get isMenuOpen => _isMenuOpen;
  String get currentPage => _currentPage;
  
  // Odnośniki do stron (tylko dla hamburger menu)
  List<MenuItem> get pageLinks {
    return _allMenuItems.where((item) {
      return item.type == MenuItemType.pageLink && 
             (item.pageFilter == null || item.pageFilter == _currentPage);
    }).toList();
  }

  // Opcje użytkownika (dla menu po prawej)
  List<MenuItem> getUserActions(String pageName) {
    return _allMenuItems.where((item) {
      return item.type == MenuItemType.userAction && 
             (item.pageFilter == null || item.pageFilter == pageName);
    }).toList();
  }

  // Opcje globalne (dostępne w obu miejscach)
  List<MenuItem> get globalActions {
    return _allMenuItems.where((item) {
      return item.type == MenuItemType.global;
    }).toList();
  }

  MenuProvider() {
    _initializeMenuItems();
  }

  void _initializeMenuItems() {
    _allMenuItems = [
      // ODNIEWNIKI DO STRON (tylko w hamburger menu) - MenuItemType.pageLink
      MenuItem(
        title: 'Welcome Page',
        icon: Icons.home, // To jest ignorowane dla Welcome Page w hamburgerze
        route: '/welcome', // To powinno prowadzić do Twojej WelcomePage
        pageFilter: 'get_started',
        type: MenuItemType.pageLink,
      ),
      MenuItem(
        title: 'Dashboard',
        icon: Icons.dashboard,
        route: '/dashboard',
        pageFilter: 'ab_cd',
        type: MenuItemType.pageLink,
      ),
      MenuItem(
        title: 'Reports',
        icon: Icons.assessment,
        route: '/reports',
        pageFilter: 'ab_cd',
        type: MenuItemType.pageLink,
      ),
      MenuItem(
        title: 'Analytics',
        icon: Icons.analytics,
        route: '/analytics',
        pageFilter: 'ab_cd',
        type: MenuItemType.pageLink,
      ),

      // AKCJE UŻYTKOWNIKA (tylko w menu profilu po prawej) - MenuItemType.userAction
      MenuItem(
        title: 'Settings',
        icon: Icons.settings,
        route: '/settings',
        pageFilter: null, // dostępne na wszystkich stronach
        type: MenuItemType.userAction,
      ),
      MenuItem(
        title: 'Profile',
        icon: Icons.person,
        route: '/profile',
        pageFilter: null,
        type: MenuItemType.userAction,
      ),
      MenuItem(
        title: 'Logout',
        icon: Icons.logout,
        route: '/logout',
        pageFilter: null,
        type: MenuItemType.userAction,
      ),

      // OPCJE GLOBALNE (dostępne wszędzie) - MenuItemType.global
      MenuItem(
        title: 'Help',
        icon: Icons.help,
        route: '/help',
        pageFilter: null,
        type: MenuItemType.global,
      ),
      MenuItem(
        title: 'About',
        icon: Icons.info,
        route: '/about',
        pageFilter: null,
        type: MenuItemType.global,
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

  void addMenuItem(MenuItem item) {
    _allMenuItems.add(item);
    notifyListeners();
  }
}