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
        // GŁÓWNA ZAWARTOŚĆ
        child,

        // MENU OVERLAY (tylko odnośniki do stron)
        Consumer<MenuProvider>(
          builder: (context, menuProvider, child) {
            if (!menuProvider.isMenuOpen) return const SizedBox.shrink();

            return Stack(
              children: [
                // PRZYCIMNIONE TŁO
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => menuProvider.closeMenu(),
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                ),

                // PANEL Z ODNIEWNIKAMI
                Positioned(
                  top: MediaQuery.of(context).padding.top + kToolbarHeight,
                  left: 8,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ODNIEWNIKI DO STRON - ZACHOWANY KOLOR #860E66
                          ...menuProvider.pageLinks.map((item) {
                            return ListTile(
                              leading: Icon(item.icon, color: const Color(0xFF860E66)),
                              title: Text(
                                item.title,
                                style: const TextStyle(
                                  color: Color(0xFF860E66),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onTap: () {
                                menuProvider.closeMenu();
                                Navigator.pushNamed(context, item.route);
                              },
                            );
                          }).toList(),
                          
                          // OPCJE GLOBALNE W HAMBURGER MENU - SZARY KOLOR
                          if (menuProvider.globalActions.isNotEmpty) ...[
                            const Divider(height: 1, thickness: 1),
                            ...menuProvider.globalActions.map((item) {
                              return ListTile(
                                leading: Icon(item.icon, color: Colors.grey[600]),
                                title: Text(
                                  item.title,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                onTap: () {
                                  menuProvider.closeMenu();
                                  Navigator.pushNamed(context, item.route);
                                },
                              );
                            }).toList(),
                          ],
                          
                          // DODATKOWY MARGINES NA DOLE DLA LEPSZEGO WYGLĄDU
                          const SizedBox(height: 8),
                        ],
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