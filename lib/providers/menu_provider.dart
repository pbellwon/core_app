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
    _log('🆕 [MenuProvider] Constructor called');
    _initializeMenuItems();
  }

  bool get isMenuOpen => _isMenuOpen;
  String get currentPage => _currentPage;

  // Odnośniki do stron (tylko dla hamburger menu)
  List<MenuItem> get pageLinks {
    final filteredItems = _allMenuItems.where((item) {
      final isPageLink = item.type == MenuItemType.pageLink;
      
      // Logika filtrowania:
      // 1. Musi być pageLink
      // 2. Jeśli ma pageFilter → pokaż tylko gdy matches currentPage
      // 3. Jeśli nie ma pageFilter (null) → pokaż wszędzie
      final filterMatches = item.pageFilter == null || item.pageFilter == _currentPage;
      final matches = isPageLink && filterMatches;

      if (item.title == 'Get Started Page' || item.title == 'Welcome Page') {
        _log('🔍 [MenuProvider] Checking ${item.title}:');
        _log('   - Type: ${item.type}, isPageLink: $isPageLink');
        _log('   - Filter: ${item.pageFilter}, Current: $_currentPage');
        _log('   - Filter matches: $filterMatches');
        _log('   - Matches: $matches');
      }

      return matches;
    }).toList();

    _log('📋 [MenuProvider] pageLinks for "$_currentPage": ${filteredItems.length}');

    return filteredItems;
  }

  // Opcje użytkownika (menu po prawej)
  List<MenuItem> getUserActions(String pageName) {
    final filteredItems = _allMenuItems.where((item) {
      return item.type == MenuItemType.userAction &&
          (item.pageFilter == null || item.pageFilter == pageName);
    }).toList();

    _log('👤 [MenuProvider] getUserActions for "$pageName": ${filteredItems.length}');

    return filteredItems;
  }

  // Opcje globalne (wszędzie)
  List<MenuItem> get globalActions {
    final filteredItems = _allMenuItems.where((item) => item.type == MenuItemType.global).toList();

    _log('🌐 [MenuProvider] globalActions: ${filteredItems.length}');

    return filteredItems;
  }

  void _initializeMenuItems() {
    _allMenuItems = [
      // PAGE LINKS - pokazują się w hamburger menu
      
      // Welcome Page - TYLKO na Get Started Page
      MenuItem(
        title: 'Welcome Page',
        icon: Icons.home, // lub Icons.waving_hand, Icons.emoji_emotions
        route: '/welcome',
        pageFilter: 'get_started', // TYLKO gdy currentPage == 'get_started'
        type: MenuItemType.pageLink,
      ),

      // Get Started Page - TYLKO na Welcome Page
      MenuItem(
        title: 'Get Started Page',
        icon: Icons.play_arrow, // lub Icons.rocket_launch, Icons.directions_run
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

    _log('✅ [MenuProvider] Menu items initialized: ${_allMenuItems.length}');
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
    _log('📍 [MenuProvider] Current page set to "$_currentPage"');
    notifyListeners();
  }

  void addMenuItem(MenuItem item) {
    _allMenuItems.add(item);
    notifyListeners();
  }

  /// 🔑 Funkcja wylogowania użytkownika
  void logoutUser() {
    _log('🚪 [MenuProvider] Logging out user...');
    if (navigatorKey == null) {
      _log('❌ [MenuProvider] navigatorKey is null, cannot log out');
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

  List<String> getAvailablePageTitles() => pageLinks.map((item) => item.title).toList();

  // ⭐ Warunkowe logowanie tylko w trybie debug
  void _log(String message) {
    assert(() {
      debugPrint(message);
      return true;
    }());
  }
}