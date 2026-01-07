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

        // MENU OVERLAY
        Consumer<MenuProvider>(
          builder: (context, menuProvider, child) {
            if (!menuProvider.isMenuOpen) return const SizedBox.shrink();

            return Stack(
              children: [
                // PRZYCIMNIONE TŁO (zamyka menu po kliknięciu)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => menuProvider.closeMenu(),
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                ),

                // MENU PANEL
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
                          // NAGŁÓWEK
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.menu, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  'Menu - ${menuProvider.currentPage.replaceAll('_', ' ').toUpperCase()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // OPCJE MENU
                          ...menuProvider.currentPageMenuItems.map((item) {
                            return ListTile(
                              leading: Icon(item.icon, color: const Color(0xFF860E66)),
                              title: Text(
                                item.title,
                                style: const TextStyle(color: Color(0xFF860E66)),
                              ),
                              onTap: () {
                                menuProvider.closeMenu();
                                // Tutaj nawigacja do odpowiedniej strony
                                // np. Navigator.pushNamed(context, item.route);
                              },
                            );
                          }).toList(),

                          // SEPARATOR
                          const Divider(height: 1),

                          // OPCJE GLOBALNE (dla wszystkich stron)
                          ...menuProvider.currentPageMenuItems
                              .where((item) => item.pageFilter == null)
                              .map((item) {
                            return ListTile(
                              leading: Icon(item.icon, color: Colors.grey[600]),
                              title: Text(
                                item.title,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              onTap: () {
                                menuProvider.closeMenu();
                                // Nawigacja
                              },
                            );
                          }).toList(),
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