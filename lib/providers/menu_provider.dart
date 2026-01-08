// lib/providers/menu_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/menu_item_model.dart';
import 'auth_provider.dart';
import '../main.dart'; // dla navigatorKey
import 'package:provider/provider.dart';

class MenuProvider with ChangeNotifier {
  bool _isMenuOpen = false;
  String _currentPage = 'get_started';
  List<MenuItem> _allMenuItems = [];

  bool get isMenuOpen => _isMenuOpen;
  String get currentPage => _currentPage;

  // Page links (hamburger menu)
  List<MenuItem> get pageLinks {
    final filteredItems = _allMenuItems.where((item) {
      final isPageLink = item.type == MenuItemType.pageLink;
      final matches = isPageLink && (item.pageFilter == null || item.pageFilter == _currentPage);

      if (kDebugMode && item.title == 'Welcome Page') {
        print('🔍 [MenuProvider] Welcome Page check: matches=$matches');
      }

      return matches;
    }).toList();

    return filteredItems;
  }

  // User actions (menu po prawej)
  List<MenuItem> getUserActions(String pageName) {
    return _allMenuItems.where((item) {
      return item.type == MenuItemType.userAction &&
          (item.pageFilter == null || item.pageFilter == pageName);
    }).toList();
  }

  // Global actions (wszędzie)
  List<MenuItem> get globalActions {
    return _allMenuItems.where((item) => item.type == MenuItemType.global).toList();
  }

  MenuProvider() {
    if (kDebugMode) print('🆕 [MenuProvider] Constructor called');
    _initializeMenuItems();
  }

  void _initializeMenuItems() {
    _allMenuItems = [
      // PAGE LINKS
      MenuItem(
        title: 'Welcome Page',
        icon: null, // <--- brak ikony
        route: '/welcome',
        pageFilter: 'get_started',
        type: MenuItemType.pageLink,
      ),
    ];

    if (kDebugMode) print('✅ [MenuProvider] Menu items initialized: ${_allMenuItems.length}');
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
    if (kDebugMode) print('📍 [MenuProvider] Current page set to "$_currentPage"');
    notifyListeners();
  }

  void addMenuItem(MenuItem item) {
    _allMenuItems.add(item);
    notifyListeners();
  }

  // Wylogowanie użytkownika
  void logoutUser() {
    if (kDebugMode) print('🚪 [MenuProvider] Logging out user...');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final context = navigatorKey.currentContext;
        if (context != null) {
          Provider.of<AppAuthProvider>(context, listen: false).signOut();
        }
      } catch (e) {
        if (kDebugMode) print('❌ [MenuProvider] logoutUser failed: $e');
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

  List<String> getAvailablePageTitles() => pageLinks.map((item) => item.title).toList();
}
