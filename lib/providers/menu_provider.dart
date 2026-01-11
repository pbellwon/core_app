// lib/providers/menu_provider.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/menu_item_model.dart';
import 'auth_provider.dart';

class MenuProvider with ChangeNotifier {
  bool _isMenuOpen = false;
  String _currentPage = 'get_started';
  List<MenuItem> _allMenuItems = [];

  final GlobalKey<NavigatorState>? navigatorKey;

  MenuProvider({this.navigatorKey}) {
    _initializeMenuItems();
  }

  bool get isMenuOpen => _isMenuOpen;
  String get currentPage => _currentPage;

  // Odnośniki do stron (tylko dla hamburger menu)
  List<MenuItem> get pageLinks {
    return _allMenuItems.where((item) {
      final isPageLink = item.type == MenuItemType.pageLink;
      final filterMatches = item.pageFilter == null || item.pageFilter == _currentPage;
      return isPageLink && filterMatches;
    }).toList();
  }

  // Opcje użytkownika (menu po prawej)
  List<MenuItem> getUserActions(String pageName) {
    return _allMenuItems.where((item) {
      return item.type == MenuItemType.userAction &&
          (item.pageFilter == null || item.pageFilter == pageName);
    }).toList();
  }

  // Opcje globalne (wszędzie)
  List<MenuItem> get globalActions {
    return _allMenuItems.where((item) => item.type == MenuItemType.global).toList();
  }

  void _initializeMenuItems() {
    _allMenuItems = [
      // PAGE LINKS - pokazują się w hamburger menu
      
      // Welcome Page - TYLKO na Get Started Page
      MenuItem(
        title: 'Welcome Page',
        icon: null,
        route: '/welcome',
        pageFilter: 'get_started', // TYLKO gdy currentPage == 'get_started'
        type: MenuItemType.pageLink,
      ),

      // Get Started Page - TYLKO na Welcome Page
      MenuItem(
        title: 'Get Started Page',
        icon: null,
        route: '/get_started',
        pageFilter: 'welcome', // TYLKO gdy currentPage == 'welcome'
        type: MenuItemType.pageLink,
      ),

      // Dashboard, Reports, Analytics - TYLKO na stronie AB CD
      MenuItem(
        title: 'Dashboard',
        icon: Icons.dashboard,
        route: '/dashboard',
        pageFilter: 'ab_cd', // TYLKO gdy currentPage == 'ab_cd'
        type: MenuItemType.pageLink,
      ),
      MenuItem(
        title: 'Reports',
        icon: Icons.assessment,
        route: '/reports',
        pageFilter: 'ab_cd', // TYLKO gdy currentPage == 'ab_cd'
        type: MenuItemType.pageLink,
      ),
      MenuItem(
        title: 'Analytics',
        icon: Icons.analytics,
        route: '/analytics',
        pageFilter: 'ab_cd', // TYLKO gdy currentPage == 'ab_cd'
        type: MenuItemType.pageLink,
      ),

      // USER ACTIONS - pokazują się w menu użytkownika (po prawej)
      MenuItem(
        title: 'Settings',
        icon: Icons.settings,
        route: '/settings',
        pageFilter: null, // WSZĘDZIE
        type: MenuItemType.userAction,
      ),
      MenuItem(
        title: 'Profile',
        icon: Icons.person,
        route: '/profile',
        pageFilter: null, // WSZĘDZIE
        type: MenuItemType.userAction,
      ),
      MenuItem(
        title: 'Logout',
        icon: Icons.logout,
        route: '/logout',
        pageFilter: null, // WSZĘDZIE
        type: MenuItemType.userAction,
      ),

      // GLOBAL ACTIONS - pokazują się wszędzie
      MenuItem(
        title: 'Help',
        icon: Icons.help,
        route: '/help',
        pageFilter: null, // WSZĘDZIE
        type: MenuItemType.global,
      ),
      
      MenuItem(
        title: 'About',
        icon: Icons.info,
        route: '/about',
        pageFilter: null, // WSZĘDZIE
        type: MenuItemType.global,
      ),
    ];
  }

  void toggleMenu() {
    _isMenuOpen = !_isMenuOpen;
    notifyListeners();
  }

  void closeMenu() {
    if (_isMenuOpen) _isMenuOpen = false;
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

  /// 🔑 Funkcja wylogowania użytkownika
  void logoutUser() {
    if (navigatorKey == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey!.currentContext;
      if (context != null) {
        Provider.of<AppAuthProvider>(context, listen: false).signOut();
      }
    });
  }

  // Helpery
  bool pageExists(String pageName) => _allMenuItems.any((item) => item.title == pageName);

  MenuItem? findMenuItem(String pageTitle) {
    try {
      return _allMenuItems.firstWhere((item) => item.title == pageTitle);
    } catch (_) {
      return null;
    }
  }

  List<String> getAvailablePageTitles() {
    final titles = <String>[];
    for (final item in pageLinks) {
      titles.add(item.title);
    }
    return titles;
  }
}