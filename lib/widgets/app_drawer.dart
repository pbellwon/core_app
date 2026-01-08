// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';
import '../providers/auth_provider.dart'; 
import '../models/menu_item_model.dart';
import '../main.dart'; // dla navigatorKey

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Consumer<MenuProvider>(
          builder: (context, menuProvider, _) {
            final pageLinks = menuProvider.pageLinks;

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Color(0xFF860E66)),
                  child: Text(
                    'Menu',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),

                // Strony typu pageLink
                for (var item in pageLinks)
                  ListTile(
                    leading: Icon(item.icon, color: const Color(0xFF860E66)),
                    title: Text(item.title),
                    onTap: () {
                      Navigator.of(context).pop(); // Zamknij Drawer
                      menuProvider.closeMenu();     // Zresetuj overlay
                      // Nawigacja
                      if (item.route == '/logout') {
                        _handleLogout(context);
                      } else {
                        navigatorKey.currentState?.pushNamed(item.route);
                      }
                    },
                  ),

                const Divider(),
      ],
            );
          },
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<AppAuthProvider>(context, listen: false).signOut();
              navigatorKey.currentState?.pushNamedAndRemoveUntil(
                '/login', 
                (route) => false,
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Color(0xFF860E66)),
            ),
          ),
        ],
      ),
    );
  }
}
