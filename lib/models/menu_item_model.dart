// lib/models/menu_item_model.dart
import 'package:flutter/widgets.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final String route;
  final bool requiresAuth;
  final String? pageFilter;

  const MenuItem({
    required this.title,
    required this.icon,
    required this.route,
    this.requiresAuth = true,
    this.pageFilter,
  });

  @override
  String toString() => 'MenuItem(title: $title, route: $route)';
}