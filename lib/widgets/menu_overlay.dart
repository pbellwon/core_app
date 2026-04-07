// lib/widgets/menu_overlay.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';

class MenuOverlay extends StatelessWidget {
  final Widget child;

  const MenuOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Consumer<MenuProvider>(
          builder: (context, menuProvider, _) {
            if (!menuProvider.isMenuOpen) return const SizedBox.shrink();

            // Pobierz dynamiczne pozycje menu
            final pageLinks = menuProvider.pageLinks;
            final globalActions = menuProvider.globalActions;
            final allMenuItems = [...pageLinks, ...globalActions];

            return Stack(
              children: [
                // Tło zamykające menu
                GestureDetector(
                  onTap: () => menuProvider.closeMenu(),
                  child: Container(
                    color: const Color.fromRGBO(0, 0, 0, 0.3),
                  ),
                ),
                // Menu
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {},
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          margin: const EdgeInsets.only(top: 8, left: 8),
                          width: 250,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromRGBO(0, 0, 0, 0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: allMenuItems.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = allMenuItems[index];
                              return ListTile(
                                leading: item.icon != null
                                    ? Icon(item.icon, color: const Color(0xFF860E66))
                                    : null,
                                title: Text(
                                  item.title,
                                  style: const TextStyle(
                                    color: Color(0xFF860E66),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                onTap: () {
                                  menuProvider.closeMenu();
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).pushNamed(item.route);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}