import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'get_started.dart';

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
  bool termsAccepted = false;

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
        title: const Text('Terms & Conditions'),
        content: const SingleChildScrollView(
          child: Text(
            'TU WKLEJ PEŁNĄ TREŚĆ TERMS & CONDITIONS...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
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
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => GetStarted()),
        );
      } else {
        // ===== REGISTER =====
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final uid = userCredential.user?.uid;
        if (uid != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .set({
            'email': email,
            'accepted_terms_at': DateTime.now().toIso8601String(),
          }, SetOptions(merge: true));
        }

        if (!mounted) return;

        // Po rejestracji → wracamy do LOGIN (czysty ekran)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );

        // Opcjonalny feedback UX
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account created successfully. You can now log in.',
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Something went wrong. Please try again.';

      // LOGIN errors
      if (isLogin && e.code == 'user-not-found') {
        message = 'This email is not registered as a user';
      } else if (isLogin && e.code == 'wrong-password') {
        message = 'Incorrect password';
      } else if (isLogin && e.code == 'invalid-email') {
        message = 'Please enter a valid email address';
      }

      // REGISTER errors
      else if (!isLogin && e.code == 'email-already-in-use') {
        message = 'This email is already registered';
      } else if (!isLogin && e.code == 'weak-password') {
        message = 'Password should be at least 6 characters';
      }

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
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
        title: const Text(
          'Welcome to the Core App',
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
                      enabled: isLogin || termsAccepted,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      enabled: isLogin || termsAccepted,
                      decoration:
                          const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),

                    // Checkbox tylko przy rejestracji
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
                                text: const TextSpan(
                                  style: TextStyle(color: Colors.black),
                                  children: [
                                    TextSpan(text: 'I agree to '),
                                    TextSpan(
                                      text: 'terms & conditions',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration:
                                            TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: isLogin || termsAccepted ? submit : null,
                      child: Text(isLogin ? 'Login' : 'Register'),
                    ),
                    TextButton(
                      onPressed: toggleForm,
                      child: Text(
                        isLogin
                            ? "Don't have an account? Register"
                            : 'Have an account? Login',
                      ),
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
