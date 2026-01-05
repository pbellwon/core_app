import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'welcome_page.dart';
import 'login_page.dart';

class GetStarted extends StatefulWidget {
  final bool justRegistered;

  const GetStarted({super.key, this.justRegistered = false});

  @override
  State<GetStarted> createState() => GetStartedState();
}

class GetStartedState extends State<GetStarted> {
  bool _isMenuOpen = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<Map<String, String>> _pages = [
    {'name': 'Welcome Page', 'route': '/welcome'},
    {'name': 'Page 2', 'route': '/page2'},
    {'name': 'Page 3', 'route': '/page3'},
  ];

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

  Future<void> _signOutAndGotoLogin() async {
    await _auth.signOut();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _navigateToPage(String routeName) {
    setState(() {
      _isMenuOpen = false;
    });

    if (routeName == '/welcome') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WelcomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            setState(() {
              _isMenuOpen = !_isMenuOpen;
            });
          },
        ),
        title: const Text(
          'Get started',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOutAndGotoLogin,
          ),
        ],
      ),
      body: Stack(
        children: [
          /// =======================
          /// MAIN CONTENT
          /// =======================
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomePage()),
                );
              },
              child: const Text('Core Content'),
            ),
          ),

          /// =======================
          /// OVERLAY (zamyka menu)
          /// =======================
          if (_isMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isMenuOpen = false;
                  });
                },
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),

          /// =======================
          /// MENU (NA WIERZCHU!)
          /// =======================
          if (_isMenuOpen)
            Positioned(
              // ZMIANA: Ustawiamy menu bezpośrednio pod ikoną hamburgera
              // Używamy 0 lub minimalnej wartości, aby menu było zaraz pod AppBar
              top: MediaQuery.of(context).padding.top + 0, // Zmniejszona wartość dla lepszego wyrównania
              left: 8, // Lekkie przesunięcie w lewo dla lepszego wyrównania z ikoną
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _pages.map((page) {
                      return InkWell(
                        onTap: () => _navigateToPage(page['route']!),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              page['name']!,
                              style: const TextStyle(
                                color: Color(0xFF860E66),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}