// lib/get_started.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/menu_provider.dart';

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
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final menuProvider = Provider.of<MenuProvider>(context, listen: false);
        menuProvider.setCurrentPage('get_started');
      } catch (e) {
        debugPrint('Error setting current page: $e');
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
                color: Color(0xFF860E66).withAlpha((255 * 0.8).toInt()),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            // Prosty panel informacyjny zamiast debug
            Card(
              elevation: 4,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 50,
                      color: Color(0xFF860E66),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Welcome to the Application',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF860E66),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'You are successfully logged in and ready to use all features.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Menu Status Info (uproszczone)
            Consumer<MenuProvider>(
              builder: (context, menuProvider, child) {
                return Card(
                  elevation: 2,
                  color: const Color(0xFFFBF3F9),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Application Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF860E66),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Text(
                              'Current Page: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(menuProvider.currentPage),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Text(
                              'Available Pages: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('${menuProvider.pageLinks.length} items'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}