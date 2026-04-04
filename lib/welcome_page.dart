// lib/welcome_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/menu_provider.dart';

class WelcomePage extends StatefulWidget {
  final bool justRegistered;

  const WelcomePage({
    super.key, 
    this.justRegistered = false,
  });

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final menuProvider = Provider.of<MenuProvider>(context, listen: false);
        menuProvider.setCurrentPage('welcome');
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Tytuł strony
                Text(
                  'Welcome Page',
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
                const SizedBox(height: 40),
                // Główny panel powitalny
                Card(
                  elevation: 4,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 60,
                          color: Color(0xFF860E66),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Welcome to the Application Dana TEST site',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF860E66),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'You are successfully logged in and ready to use all features. '
                          'Navigate through the app using the menu drawer.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Centered button to go to Get Started
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/get_started');
                  },
                  child: const Text('Go to Get Started'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}