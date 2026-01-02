import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'terms_and_conditions.dart';
import 'login_page.dart';

class CoreContentPage extends StatefulWidget {
  const CoreContentPage({super.key});

  @override
  _CoreContentPageState createState() => _CoreContentPageState();
}

class _CoreContentPageState extends State<CoreContentPage> {
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
          "Welome to Core Content",
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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "What kind of expirience would be most helpful for You in this moment ?",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            // BUTTON 1
            ElevatedButton(
              onPressed: () {
                // TODO: przejście do odpowiedniej podstrony
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: Text("Help me reconnect"),
            ),

            SizedBox(height: 20),

            // BUTTON 2
            ElevatedButton(
              onPressed: () {
                // TODO: przejście do odpowiedniej podstrony
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: Text("Show me what's possible"),
            ),

            SizedBox(height: 20),

            // BUTTON 3
            ElevatedButton(
              onPressed: () {
                // TODO: przejście do odpowiedniej podstrony
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: Text("Go to my favourites"),
            ),
          ],
        ),
      ),
    );
  }
}
