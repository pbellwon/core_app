// lib/widgets/main_app_bar.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart' show navigatorKey;
import '../login_page.dart';
import '../providers/auth_provider.dart';
import '../providers/menu_provider.dart';
import '../models/user_model.dart';
import '../models/menu_item_model.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;

  const MainAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title.isNotEmpty ? Text(title) : null,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
          : Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
      centerTitle: false,
      titleSpacing: showBackButton ? 0 : 16,
      actions: [
        Consumer<AppAuthProvider>(
          builder: (context, authProvider, child) {
            if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
              return Container();
            }
            return UserProfileButton(user: authProvider.currentUser!);
          },
        ),
        ...?actions,
      ],
    );
  }
}

class UserProfileButton extends StatelessWidget {
  final AppUser user;

  const UserProfileButton({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    final userActions = menuProvider.getUserActions(menuProvider.currentPage);
    final globalActions = menuProvider.globalActions;
    
    final allActions = [...userActions, ...globalActions];

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: PopupMenuButton<MenuItem>(
        offset: const Offset(0, kToolbarHeight),
        onSelected: (MenuItem item) {
          _handleMenuItemSelection(context, item);
        },
        itemBuilder: (BuildContext context) {
          final items = <PopupMenuEntry<MenuItem>>[];
          
          // Nagłówek z profilem
          items.add(
            PopupMenuItem<MenuItem>(
              enabled: false,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFF860E66),
                    child: Text(
                      user.email.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName ?? user.email.split('@')[0],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
          
          items.add(const PopupMenuDivider());
          
          // Lista akcji
          for (var item in allActions) {
            items.add(
              PopupMenuItem<MenuItem>(
                value: item,
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: 20,
                      color: item.title == 'Logout' ? Color(0xFF860E66) : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item.title,
                      style: TextStyle(
                        color: item.title == 'Logout' ? Color(0xFF860E66) : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          return items;
        },
        child: Container(
          height: kToolbarHeight,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF860E66),
                foregroundColor: Colors.white,
                child: Text(
                  user.email.substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName ?? user.email.split('@')[0],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB31288),
                    ),
                  ),
                ],
              ),
              const Icon(Icons.arrow_drop_down, color: Color(0xFFB31288)),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuItemSelection(BuildContext context, MenuItem item) {
    print('🔍 Menu item selected: ${item.title}, route: ${item.route}');
    
    if (item.route == '/logout') {
      _showLogoutDialog(context);
    } else {
      print('🚀 Navigating to: ${item.route}');
      Navigator.pushNamed(context, item.route).then((_) {
        print('✅ Navigation completed');
      }).catchError((e) {
        print('❌ Navigation error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigation failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  void _showLogoutDialog(BuildContext context) {
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
            onPressed: () async {
              // 1. Zamknij dialog
              Navigator.of(context).pop();
              
              try {
                // 2. Wyloguj użytkownika
                await Provider.of<AppAuthProvider>(context, listen: false).signOut();
                
                // 3. Czekaj na pełne wylogowanie z Firebase
                await Future.delayed(const Duration(milliseconds: 500));
                
                // 4. ✅ PROSTA NAWIGACJA DLA WSZYSTKICH PLATFORM
                navigatorKey.currentState?.pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                  (route) => false,
                );
                
                print('✅ Logout successful - navigated to LoginPage');
                
              } catch (e) {
                print('❌ Logout error: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logout failed: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
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