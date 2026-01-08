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
                      color: const Color.fromRGBO(0, 0, 0, 0.3),
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
                          // ODNIEWNIKI DO STRON
                          ...menuProvider.pageLinks.map((item) {
                            // Sprawdź czy to Welcome Page - jeśli tak, to bez ikony
                            final bool isWelcomePage = item.title == 'Welcome Page';
                            
                            return ListTile(
                              leading: isWelcomePage 
                                  ? null // Bez ikony dla Welcome Page
                                  : Icon(item.icon, color: const Color(0xFF860E66)),
                              title: Text(
                                item.title,
                                style: const TextStyle(
                                  color: Color(0xFF860E66),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onTap: () {
                                // DEBUG: Logowanie które kliknięto
                                debugPrint('MenuOverlay: Kliknięto "${item.title}" -> route: "${item.route}"');
                                
                                menuProvider.closeMenu();
                                
                                // Nawigacja do odpowiedniej strony
                                try {
                                  if (item.route == '/logout') {
                                    // Logout jest obsługiwany w UserProfileButton
                                    debugPrint('MenuOverlay: Logout powinien być obsługiwany w profilu');
                                    return;
                                  }
                                  
                                  // Użyj Navigator.pushNamed dla nawigacji
                                  Navigator.pushNamed(context, item.route)
                                    .then((_) {
                                      // Po powrocie z nawigacji możesz coś zrobić
                                      debugPrint('MenuOverlay: Powrót z ${item.route}');
                                    })
                                    .catchError((error) {
                                      // Jeśli wystąpi błąd nawigacji
                                      debugPrint('MenuOverlay: Błąd nawigacji do ${item.route}: $error');
                                      _showNavigationError(context, item.title);
                                    });
                                } catch (e) {
                                  debugPrint('MenuOverlay: Wyjątek podczas nawigacji: $e');
                                  _showNavigationError(context, item.title);
                                }
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
                                  debugPrint('MenuOverlay: Kliknięto globalne "${item.title}" -> route: "${item.route}"');
                                  
                                  menuProvider.closeMenu();
                                  
                                  try {
                                    if (item.route == '/logout') {
                                      debugPrint('MenuOverlay: Global Logout - obsługa w profilu');
                                      return;
                                    }
                                    
                                    Navigator.pushNamed(context, item.route)
                                      .then((_) {
                                        debugPrint('MenuOverlay: Powrót z globalnej strony ${item.route}');
                                      })
                                      .catchError((error) {
                                        debugPrint('MenuOverlay: Błąd nawigacji do globalnej ${item.route}: $error');
                                        _showNavigationError(context, item.title);
                                      });
                                  } catch (e) {
                                    debugPrint('MenuOverlay: Wyjątek podczas nawigacji globalnej: $e');
                                    _showNavigationError(context, item.title);
                                  }
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
  
  // Funkcja do pokazywania błędu nawigacji
  void _showNavigationError(BuildContext context, String pageName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nie można przejść do "$pageName" - strona nie została zaimplementowana'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}