import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/menu_item_model.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/menu_provider.dart';
import '../main.dart'; // 🔑 navigatorKey

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
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
      centerTitle: false,
      titleSpacing: showBackButton ? 0 : 16,
      actions: [
        Consumer<AppAuthProvider>(
          builder: (context, authProvider, _) {
            if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
              return const SizedBox.shrink();
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
    final menuProvider = context.read<MenuProvider>();
    final userActions = menuProvider.getUserActions(menuProvider.currentPage);
    final globalActions = menuProvider.globalActions;
    final allActions = [...userActions, ...globalActions];

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: PopupMenuButton<MenuItem>(
        offset: const Offset(0, kToolbarHeight),
        onSelected: (item) => _onMenuItemSelected(context, item),
        itemBuilder: (_) => _buildMenuItems(allActions),
        child: _buildProfileHeader(),
      ),
    );
  }

  List<PopupMenuEntry<MenuItem>> _buildMenuItems(List<MenuItem> actions) {
    final items = <PopupMenuEntry<MenuItem>>[];

    items.add(
      PopupMenuItem<MenuItem>(
        enabled: false,
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF860E66),
              child: Text(
                user.email.substring(0, 1).toUpperCase(),
                style: const TextStyle(
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
                  style: const TextStyle(fontWeight: FontWeight.bold),
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

    for (final item in actions) {
      items.add(
        PopupMenuItem<MenuItem>(
          value: item,
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 20,
                color: item.title == 'Logout'
                    ? const Color(0xFF860E66)
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                item.title,
                style: TextStyle(
                  color: item.title == 'Logout'
                      ? const Color(0xFF860E66)
                      : null,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return items;
  }

  Widget _buildProfileHeader() {
    return Container(
      height: kToolbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF860E66),
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
                style: const TextStyle(fontWeight: FontWeight.bold),
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
    );
  }

  void _onMenuItemSelected(BuildContext context, MenuItem item) async {
    if (item.route == '/logout') {
      await _logout(context);
    } else {
      navigatorKey.currentState?.pushNamed(item.route);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final auth = context.read<AppAuthProvider>();

    // 1️⃣ Firebase logout
    await auth.signOut();

    // 2️⃣ 🔥 WYMUŚ POWRÓT NA ROOT
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/',
      (route) => false,
    );
  }
}
