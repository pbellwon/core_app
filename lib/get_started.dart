// lib/get_started.dart (uproszczone)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'welcome_page.dart';
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
      Provider.of<MenuProvider>(context, listen: false)
          .setCurrentPage('get_started');
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Get Started Page',
            style: TextStyle(
              fontSize: 24,
              color: const Color(0xFF860E66),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WelcomePage()),
              );
            },
            child: const Text('Go to Welcome Page'),
          ),
        ],
      ),
    );
  }
}