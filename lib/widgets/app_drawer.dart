// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 0), // miejsce po starym DrawerHeader

          // PAGE LINKS
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: menuProvider.pageLinks.map((item) {
                return ListTile(
                  leading: item.icon != null ? Icon(item.icon!) : null,
                  title: Text(
                    item.title,
                    style: const TextStyle(color: Color(0xFF860E66)),
                  ),
                  onTap: () {
                    Navigator.pop(context); // zamknij drawer
                    
                    // WAŻNE: Najpierw ustaw currentPage dla strony docelowej
                    final targetPageId = _getPageIdFromRoute(item.route);
                    menuProvider.setCurrentPage(targetPageId);
                    
                    debugPrint('🔄 AppDrawer: Przechodzę do ${item.route}, ustawiam currentPage = $targetPageId');
                    
                    // Potem przejdź do strony
                    Navigator.pushNamed(context, item.route);
                  },
                );
              }).toList(),
            ),
          ),

          const Divider(),
        ],
      ),
    );
  }

  // Pomocnicza funkcja do ekstrakcji ID strony z route
  String _getPageIdFromRoute(String route) {
    switch (route) {
      case '/welcome':
        return 'welcome';
      case '/get_started':
        return 'get_started';
      case '/dashboard':
        return 'ab_cd';
      case '/reports':
        return 'reports';
      case '/analytics':
        return 'analytics';
      default:
        // Usuwa '/' z początku
        return route.startsWith('/') ? route.substring(1) : route;
    }
  }
}