// lib/get_started.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/main_app_bar.dart';
import 'providers/menu_provider.dart';
import 'explore_my_options.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  @override
  void initState() {
    super.initState();
    // Używamy addPostFrameCallback aby mieć pewność, że context jest dostępny
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final menuProvider = Provider.of<MenuProvider>(context, listen: false);
      menuProvider.setCurrentPage('get_started');
      debugPrint('✅ GetStartedPage: currentPage ustawione na "get_started"');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: '',
        showBackButton: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Get Started Page Loaded Successfully! 🎉',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF860E66),
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
              _WelcomeButton(
                text: 'Help me reconnect',
                onPressed: () {
                  Navigator.pushNamed(context, '/help_me_reconnect');
                },
              ),
              const SizedBox(height: 20),
              _WelcomeButton(
                text: "Show me what's possible",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExploreMyOptionsPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _WelcomeButton(text: 'Go to my favourites'),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const _WelcomeButton({required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed ?? () {
        debugPrint('Przycisk "$text" naciśnięty');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(),
        child: Text(text),
      ),
    );
  }
}