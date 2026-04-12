// lib/providers/menu_provider.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/menu_item_model.dart';
import 'auth_provider.dart';

class MenuProvider with ChangeNotifier {
  bool _isMenuOpen = false;
  String _currentPage = 'get_started';
  String _lastMainPage = 'get_started'; // DODANE: pamięć ostatniej głównej strony
  List<MenuItem> _allMenuItems = [];

  final GlobalKey<NavigatorState>? navigatorKey;

  MenuProvider({this.navigatorKey}) {
    _initializeMenuItems();
  }

  bool get isMenuOpen => _isMenuOpen;
  String get currentPage => _currentPage;
  String get lastMainPage => _lastMainPage; // DODANE getter

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

      // Get Started Page - ZAWSZE widoczna
      MenuItem(
        title: 'Home',
        icon: Icons.home,
        route: '/get_started',
        pageFilter: null,
        type: MenuItemType.pageLink,
      ),
      MenuItem(
        title: 'In The Moment Support',
        icon: Icons.favorite,
        route: '/get_started',
        pageFilter: null,
        type: MenuItemType.pageLink,
      ),
      MenuItem(
        title: 'Explore My Options',
        icon: Icons.explore,
        route: '/explore_my_options',
        pageFilter: null,
        type: MenuItemType.pageLink,
      ),
      MenuItem(
        title: 'Favourites',
        icon: Icons.star,
        route: '/get_started',
        pageFilter: null,
        type: MenuItemType.pageLink,
      ),
      MenuItem(
        title: 'My Program',
        icon: Icons.check_box,
        route: '/get_started',
        pageFilter: null,
        type: MenuItemType.pageLink,
      ),      
      // USER ACTIONS - pokazują się w menu użytkownika (po prawej)
      MenuItem(
        title: 'Settings',
        icon: Icons.settings,
        route: '/settings',
        pageFilter: null,
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
      MenuItem(
        title: 'Help',
        icon: Icons.help,
        route: '/help',
        pageFilter: null,
        type: MenuItemType.userAction,
      ),     
      MenuItem(
        title: 'About',
        icon: Icons.info,
        route: '/about',
        pageFilter: null,
        type: MenuItemType.userAction,
      ),

      // GLOBAL ACTIONS - pokazują się wszędzie
     // MenuItem(
       //title: 'Terms of Service',
        //icon: Icons.help,
        //route: '/terms_of_service',
        //pageFilter: null,
        //type: MenuItemType.global,
      //),
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
    
    // DODANE: Zapamiętaj jeśli to główna strona
    if (_isMainPage(pageName)) {
      _lastMainPage = pageName;
    }
    
    notifyListeners();
  }

  bool _isMainPage(String pageName) {
    // Główne strony to te które mają hamburger menu
    return pageName == 'welcome' || 
           pageName == 'get_started' || 
           pageName == 'ab_cd';
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