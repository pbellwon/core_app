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
          // 🟢 USUNIĘTO DrawerHeader z napisem MENU
          Container(
            height: 0,
          ),

          // PAGE LINKS
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: menuProvider.pageLinks.map((item) {
                return ListTile(
                  leading: item.icon != null ? Icon(item.icon!) : null,
                  title: Text(
                    item.title,
                    style: const TextStyle(color: Color(0xFF860E66)), // heading color
                  ),
                  onTap: () {
                    Navigator.pop(context); // zamknij drawer
                    Navigator.pushNamed(context, item.route); // route NIE jest null
                    menuProvider.setCurrentPage(item.pageFilter ?? '');
                  },
                );
              }).toList(),
            ),
          ),

          const Divider(),

          // USER ACTIONS
          ...menuProvider.getUserActions(menuProvider.currentPage).map((item) {
            return ListTile(
              leading: item.icon != null ? Icon(item.icon!) : null,
              title: Text(item.title),
              onTap: () {
                Navigator.pop(context);
                if (item.title.toLowerCase() == 'logout') {
                  menuProvider.logoutUser();
                } else {
                  Navigator.pushNamed(context, item.route); // route NIE jest null
                }
              },
            );
          }),

          const Divider(),

          // GLOBAL ACTIONS
          ...menuProvider.globalActions.map((item) {
            return ListTile(
              leading: item.icon != null ? Icon(item.icon!) : null,
              title: Text(item.title),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, item.route); // route NIE jest null
              },
            );
          }),
        ],
      ),
    );
  }
}