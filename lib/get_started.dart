import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'welcome_page.dart';
import 'login_page.dart';
import 'terms_and_conditions.dart';

class GetStarted extends StatefulWidget {
  final bool justRegistered;
  const GetStarted({super.key, this.justRegistered = false});

  @override
  _GetStartedState createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  final _auth = FirebaseAuth.instance;

  Future<void> _signOutAndGotoLogin() async {
    try {
      await _auth.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
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
        title: Text(
          "Get started",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: Icon(Icons.logout),
            onPressed: _signOutAndGotoLogin,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.justRegistered)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 10),
                      Text(
                        'Your account has been created!',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Center(
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Terms & Conditions',
        mini: true,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TermsAndConditionsPage()),
          );
        },
        child: Icon(Icons.description),
      ),
    );
  }
}
