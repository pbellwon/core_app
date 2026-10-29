// lib/welcome_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/menu_provider.dart';
import 'providers/auth_provider.dart';
import 'onboarding_page.dart';

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
  // Static - survives widget recreation caused by provider rebuilds
  static bool _onboardingDialogShown = false;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final menuProvider = Provider.of<MenuProvider>(context, listen: false);
        menuProvider.setCurrentPage('welcome');

        // 🎯 CHECK: Jeśli nowy user nie skończył onboarding'u, pokaż dialog (tylko raz)
        if (!_onboardingDialogShown) {
          final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
          if (authProvider.currentUser != null && 
              !authProvider.currentUser!.onboardingCompleted) {
            _onboardingDialogShown = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const OnboardingPage(),
                );
              }
            });
          }
        }
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to the Core App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF860E66),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/explore_my_options');
              },
              child: const Text("Let's Explore"),
            ),
          ],
        ),
      ),
    );
  }
}