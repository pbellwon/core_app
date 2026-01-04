import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'get_started.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key}); // super.key nowoczesny

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLogin = true; // true = login, false = register
  bool termsAccepted = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void toggleForm() {
    setState(() {
      isLogin = !isLogin;
      termsAccepted = false;
      emailController.clear();
      passwordController.clear();
    });
  }

  Future<void> _showTermsContentDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Terms & Conditions'),
        content: SingleChildScrollView(
          child: Text('TU WKLEJ PEŁNĄ TREŚĆ TERMS & CONDITIONS...'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      if (isLogin) {
        // ===== LOGIN =====
        final credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = credential.user;
        if (user == null || !user.emailVerified) {
          await _auth.signOut();
          throw FirebaseAuthException(code: 'email-not-verified');
        }

        if (!mounted) {
          return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => GetStarted()),
        );
      } else {
        // ===== REGISTER =====
        final credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = credential.user;
        if (user != null) {
          await user.sendEmailVerification();
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'email': email,
            'accepted_terms_at': DateTime.now().toIso8601String(),
          }, SetOptions(merge: true));
        }

        // Wylogowanie po rejestracji
        await _auth.signOut();

        if (!mounted) {
          return;
        }

        // 🔑 Odświeżenie ekranu: nowy widget LoginPage z UniqueKey()
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage(key: UniqueKey())),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Account created successfully. Please verify your email before logging in.',
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Something went wrong. Please try again.';

      if (isLogin && e.code == 'user-not-found') {
        message = 'This email is not registered as a user';
      } else if (isLogin && e.code == 'wrong-password') {
        message = 'Incorrect password';
      } else if (isLogin && e.code == 'invalid-email') {
        message = 'Please enter a valid email address';
      } else if (isLogin && e.code == 'email-not-verified') {
        message = 'Please verify your email before logging in';
      } else if (!isLogin && e.code == 'email-already-in-use') {
        message = 'This email is already registered';
      } else if (!isLogin && e.code == 'weak-password') {
        message = 'Password should be at least 6 characters';
      }

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
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
          'Welcome to the Core App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: emailController,
                      enabled: isLogin || termsAccepted,
                      decoration: InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      enabled: isLogin || termsAccepted,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    SizedBox(height: 16),

                    if (!isLogin)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: termsAccepted,
                            onChanged: (val) {
                              setState(() {
                                termsAccepted = val ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: _showTermsContentDialog,
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(color: Colors.black),
                                  children: [
                                    TextSpan(text: 'I agree to '),
                                    TextSpan(
                                      text: 'terms & conditions',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: isLogin || termsAccepted ? submit : null,
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
          ],
        ),
      ),
    );
  }
}
