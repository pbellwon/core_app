// lib/welcome_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/main_app_bar.dart';
import 'widgets/app_drawer.dart';
import 'providers/menu_provider.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false)
          .setCurrentPage('welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: 'Welcome to Core Content',
        showBackButton: true,
      ),
      drawer: const AppDrawer(), // DODANE: hamburger menu
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Welcome Page Loaded Successfully! 🎉',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF860E66), // heading color
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Text(
                'What kind of experience would be most helpful for you at this moment?',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF860E66),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _WelcomeButton(text: 'Help me reconnect'),
              const SizedBox(height: 20),
              _WelcomeButton(text: "Show me what's possible"),
              const SizedBox(height: 20),
              _WelcomeButton(text: 'Go to my favourites'),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeButton extends StatelessWidget {
  final String text;

  const _WelcomeButton({required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Przycisk naciśnięty - bez debug print
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        backgroundColor: const Color(0xFFB31288), // accent color
        foregroundColor: Colors.white,
      ),
      child: Text(text),
    );
  }
}