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

            return Stack(
              children: [
                // 🔴 TŁO – zamyka menu
                GestureDetector(
                  onTap: () => menuProvider.closeMenu(),
                  child: Container(
                    color: const Color.fromRGBO(0, 0, 0, 0.3), // Zamiast withOpacity(0.3)
                  ),
                ),

                // 🟢 MENU – BLOKUJE PROPAGACJĘ TAPÓW
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {}, // ⛔ blokuje tap dla tła
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
                                color: const Color.fromRGBO(0, 0, 0, 0.2), // Zamiast withOpacity(0.2)
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // WELCOME PAGE
                              ListTile(
                                title: const Text(
                                  'Welcome Page',
                                  style: TextStyle(
                                    color: Color(0xFF860E66),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                onTap: () {
                                  menuProvider.closeMenu();
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).pushNamed('/welcome');
                                },
                              ),

                              const Divider(height: 1),

                              ListTile(
                                leading: const Icon(Icons.help, color: Colors.grey),
                                title: const Text(
                                  'Help',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                onTap: () {
                                  menuProvider.closeMenu();
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).pushNamed('/help');
                                },
                              ),

                              ListTile(
                                leading: const Icon(Icons.info, color: Colors.grey),
                                title: const Text(
                                  'About',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                onTap: () {
                                  menuProvider.closeMenu();
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).pushNamed('/about');
                                },
                              ),
                            ],
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