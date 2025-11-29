import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core_content.dart';
import 'login_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _auth = FirebaseAuth.instance;

  Future<void> _signOutAndGotoLogin() async {
    try {
      await _auth.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd przy wylogowaniu: $e')),
        );
      }
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Intro"),
        actions: [
          IconButton(
            tooltip: 'Wyloguj',
            icon: Icon(Icons.logout),
            onPressed: _signOutAndGotoLogin,
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CoreContentPage()),
            );
          },
          child: Text("Core Content"),
        ),
      ),
    );
  }
}
