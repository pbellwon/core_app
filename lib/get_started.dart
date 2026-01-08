// lib/get_started.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'welcome_page.dart';
import 'providers/menu_provider.dart';
import 'models/menu_item_model.dart'; // <-- DODAJ TEN IMPORT!

class GetStarted extends StatefulWidget {
  final bool justRegistered;

  const GetStarted({
    super.key, 
    this.justRegistered = false,
  });

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  @override
  void initState() {
    super.initState();
    print('🎬 [GetStarted] initState called');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔄 [GetStarted] Setting current page to "get_started"');
      try {
        final menuProvider = Provider.of<MenuProvider>(context, listen: false);
        menuProvider.setCurrentPage('get_started');
        
        // DEBUG: Sprawdź wszystkie pageLinks
        final pageLinks = menuProvider.pageLinks;
        print('📋 [GetStarted] Current pageLinks (${pageLinks.length}):');
        for (var i = 0; i < pageLinks.length; i++) {
          final item = pageLinks[i];
          print('   ${i + 1}. ${item.title} -> ${item.route}');
        }
        
      } catch (e) {
        print('❌ [GetStarted] Error setting current page: $e');
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.justRegistered) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Your account has been created!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('📱 [GetStarted] Building widget');
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Tytuł strony
            Text(
              'Get Started Page',
              style: TextStyle(
                fontSize: 24,
                color: const Color(0xFF860E66),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            
            // Opis
            Text(
              'This is the main starting point of the application',
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFF860E66).withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            // Przycisk do Welcome Page (test)
            Card(
              elevation: 4,
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Test Navigation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'This button should work and navigate to Welcome Page',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        print('🧪 [GetStarted] Test button: Navigating to WelcomePage');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const WelcomePage()),
                        ).then((_) {
                          print('✅ [GetStarted] Test navigation completed');
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(200, 50),
                      ),
                      child: const Text('Test: Go to Welcome Page'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Debug Info Panel
            Card(
              elevation: 4,
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Menu Debug Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    Consumer<MenuProvider>(
                      builder: (context, menuProvider, child) {
                        final pageLinks = menuProvider.pageLinks;
                        
                        // Znajdź Welcome Page w pageLinks
                        MenuItem? welcomePageItem;
                        for (var item in pageLinks) {
                          if (item.title == 'Welcome Page') {
                            welcomePageItem = item;
                            break;
                          }
                        }
                        
                        final hasWelcomePage = welcomePageItem != null;
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Basic Info
                            _buildDebugRow('Current Page', menuProvider.currentPage),
                            _buildDebugRow('Menu Open', menuProvider.isMenuOpen.toString()),
                            _buildDebugRow('Page Links', '${pageLinks.length} items'),
                            _buildDebugRow('Has Welcome Page', hasWelcomePage.toString(),
                              color: hasWelcomePage ? Colors.green : Colors.red),
                            
                            // Welcome Page Details
                            if (welcomePageItem != null) ...[
                              const SizedBox(height: 10),
                              const Text(
                                'Welcome Page Details:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              _buildDebugRow('  • Route', welcomePageItem.route),
                              _buildDebugRow('  • Page Filter', welcomePageItem.pageFilter ?? 'null'),
                              _buildDebugRow('  • Type', welcomePageItem.type.toString()),
                            ],
                            
                            if (!hasWelcomePage) ...[
                              const SizedBox(height: 10),
                              const Text(
                                '⚠️  Warning: Welcome Page not found in menu!',
                                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Possible reasons:',
                                style: TextStyle(fontSize: 12),
                              ),
                              const Text(
                                '• pageFilter mismatch (needs: "get_started")',
                                style: TextStyle(fontSize: 12),
                              ),
                              const Text(
                                '• Welcome Page not in menu items',
                                style: TextStyle(fontSize: 12),
                              ),
                              const Text(
                                '• Check console for more details',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Debug Buttons
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            print('🔧 [GetStarted] Debug: Printing all menu items');
                            final menuProvider = Provider.of<MenuProvider>(context, listen: false);
                            
                            // Prosta wersja bez metody debugPrintAllItems
                            final allItems = menuProvider.pageLinks;
                            print('📋 All pageLinks (${allItems.length}):');
                            for (var i = 0; i < allItems.length; i++) {
                              final item = allItems[i];
                              print('   ${i + 1}. ${item.title}');
                              print('      Route: ${item.route}');
                              print('      Filter: ${item.pageFilter}');
                              print('      Type: ${item.type}');
                            }
                            
                            // Show snackbar confirmation
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Menu items printed to console'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('Debug: Print Menu Items'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            print('🔄 [GetStarted] Debug: Refreshing menu');
                            final menuProvider = Provider.of<MenuProvider>(context, listen: false);
                            menuProvider.setCurrentPage('get_started'); // Refresh
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Menu refreshed'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('Debug: Refresh Menu'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            print('📋 [GetStarted] Debug: Checking all routes');
                            final menuProvider = Provider.of<MenuProvider>(context, listen: false);
                            final allItems = menuProvider.pageLinks;
                            
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Available Routes'),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: allItems.length,
                                    itemBuilder: (context, index) {
                                      final item = allItems[index];
                                      return ListTile(
                                        leading: Icon(item.icon),
                                        title: Text(item.title),
                                        subtitle: Text('Route: ${item.route}'),
                                        trailing: const Icon(Icons.chevron_right),
                                      );
                                    },
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('Debug: Show Available Routes'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Instructions
            Card(
              elevation: 2,
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Troubleshooting Instructions:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildInstruction('1. Check console for debug messages'),
                    _buildInstruction('2. Verify Welcome Page is in pageLinks'),
                    _buildInstruction('3. Check if pageFilter matches currentPage'),
                    _buildInstruction('4. Test the green button above'),
                    _buildInstruction('5. Use debug buttons for more info'),
                    const SizedBox(height: 10),
                    Text(
                      'If green button works but hamburger doesn\'t:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF860E66),
                      ),
                    ),
                    _buildInstruction('• Check menu_overlay.dart imports'),
                    _buildInstruction('• Verify navigation code in onTap'),
                    _buildInstruction('• Check console for errors'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method for debug rows
  Widget _buildDebugRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: color ?? Colors.black),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method for instructions
  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}