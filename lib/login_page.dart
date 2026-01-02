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
  final _auth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLogin = true; // true = logowanie, false = rejestracja

  void toggleForm() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  Future<bool?> _showTermsDialog() async {
    bool? accepted; // null = nic nie wybrano, true = accept, false = decline

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

    return await showDialog<bool>(
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
                    onPressed: () {
                      print('Dialog closed with X');
                      Navigator.of(context).pop(false);
                    },
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        'Please read and accept the terms and conditions to register.'),
                    SizedBox(height: 8),
                    IconButton(
                      icon: Icon(Icons.info_outline, color: Colors.blue),
                      tooltip: 'View Terms & Conditions',
                      onPressed: _showTermsContentDialog,
                    ),
                    SizedBox(height: 16),
                    // Radio buttons for single selection
                    RadioListTile<bool>(
                      title: Text('Accept'),
                      value: true,
                      groupValue: accepted,
                      onChanged: (val) {
                        setState(() {
                          accepted = val;
                        });
                      },
                    ),
                    RadioListTile<bool>(
                      title: Text('Decline'),
                      value: false,
                      groupValue: accepted,
                      onChanged: (val) {
                        setState(() {
                          accepted = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: accepted == null
                      ? null
                      : () {
                          print(
                              'Dialog closed with: ${accepted == true ? 'Accept' : 'Decline'}');
                          Navigator.of(context).pop(accepted);
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

  Future<void> submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      if (isLogin) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Logged in!')));
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => GetStarted()),
        );
      } else {
        // Show terms dialog before registering
        final accepted = await _showTermsDialog();

        if (accepted == true) {
          try {
            UserCredential userCredential =
                await _auth.createUserWithEmailAndPassword(
                    email: email, password: password);

            // Store acceptance timestamp in Firestore
            final uid = userCredential.user?.uid;
            if (uid != null) {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .set({
                'accepted_terms_at': DateTime.now().toIso8601String(),
                'email': email,
              }, SetOptions(merge: true));
            }

            // Show success message
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Success'),
                content: Text('Account has been created!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close success dialog
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => GetStarted(justRegistered: true)),
                      );
                    },
                    child: Text('Continue'),
                  ),
                ],
              ),
            );
          } catch (e) {
            print('Registration error: $e');
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Registration Error'),
                content: Text(e.toString()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          }
        } else if (accepted == false) {
          // Declined, show message and refresh page
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Registration Declined'),
              content:
                  Text('You must accept the terms and conditions to register.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginPage()),
                    );
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
        // Jeśli accepted == null (użytkownik zamknął dialog X), nic nie rób
      }
    } catch (e) {
      print('General error: $e');
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
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
                      child: Text(isLogin
                          ? "Don't have an account? Register"
                          : 'Have an account? Login'),
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
    );
  }
}