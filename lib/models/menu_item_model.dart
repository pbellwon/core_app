// lib/models/menu_item_model.dart
import 'package:flutter/material.dart'; // DODAJ TEN IMPORT

class MenuItem {
  final String title;
  final IconData? icon;
  final String route;
  final String? pageFilter;
  final MenuItemType type;

  MenuItem({
    required this.title,
    required this.icon,
    required this.route,
    this.pageFilter,
    required this.type,
  });
}

enum MenuItemType {
  pageLink,    // Odnośnik do strony (w hamburgerze)
  userAction,  // Akcja użytkownika (w profilu po prawej)
  global,      // Globalne opcje (w obu miejscach)
}