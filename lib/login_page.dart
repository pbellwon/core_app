import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'get_started.dart';
import 'terms_and_conditions.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    bool _acceptedTerms = false;

    Future<bool?> _showTermsDialog() async {
      bool accepted = false;
      bool declined = false;
      Future<void> _showTermsContentDialog() async {
        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Terms & Conditions'),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Text('terms & conditions'),
              ),
            );
          },
        );
      }
      return showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Terms and Conditions'),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Please read and accept the terms and conditions to register.'),
                      SizedBox(height: 8),
                      IconButton(
                        icon: Icon(Icons.info_outline, color: Colors.blue),
                        tooltip: 'View Terms & Conditions',
                        onPressed: _showTermsContentDialog,
                      ),
                      SizedBox(height: 8),
                      CheckboxListTile(
                        title: Text('Accept'),
                        value: accepted,
                        onChanged: (val) {
                          setState(() {
                            accepted = val ?? false;
                            if (accepted) declined = false;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: Text('Decline'),
                        value: declined,
                        onChanged: (val) {
                          setState(() {
                            declined = val ?? false;
                            if (declined) accepted = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: !accepted && !declined
                        ? null
                        : () {
                            Navigator.of(context).pop(accepted ? true : false);
                          },
                    child: Text('Continue'),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  final _auth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLogin = true; // true = logowanie, false = rejestracja

  void toggleForm() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  Future<void> submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      if (isLogin) {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logged in!')));
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => GetStarted()),
        );
      } else {
        // Show terms dialog before registering
        final accepted = await _showTermsDialog();
        if (accepted == true) {
          UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
          // Store acceptance timestamp in Firestore
          final uid = userCredential.user?.uid;
          if (uid != null) {
            await FirebaseFirestore.instance.collection('users').doc(uid).set({
              'accepted_terms_at': DateTime.now().toIso8601String(),
              'email': email,
            }, SetOptions(merge: true));
          }
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => GetStarted(justRegistered: true)),
          );
        } else if (accepted == false) {
          // Declined, go back to starting page
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginPage()),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isLogin ? 'Welcome to the Core App' : 'Welcome to the Core App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: submit,
                      child: Text(isLogin ? 'Login' : 'Register'),
                    ),
                    TextButton(
                      onPressed: toggleForm,
                      child: Text(isLogin ? "Don't have an account? Register" : 'Have an account? Login'),
                    ),
                  ],
                ),
              ),
            ),

            // Small agreement text at the bottom center
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'By using this page you agree to terms & conditions',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
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
