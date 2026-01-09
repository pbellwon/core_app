// lib/login_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLogin = true; // true = logowanie, false = rejestracja
  bool termsAccepted = false;
  bool _isLoading = false;  // Dodane dla stanu ładowania

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

  // ================= VALIDACJA =================

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _validateInputs() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Walidacja emaila
    if (email.isEmpty) {
      _showErrorDialog('Please enter your email address');
      return false;
    }

    if (!_isValidEmail(email)) {
      _showErrorDialog('Please enter a valid email address');
      return false;
    }

    // Walidacja hasła
    if (password.isEmpty) {
      _showErrorDialog('Please enter your password');
      return false;
    }

    if (!isLogin && password.length < 6) {
      _showErrorDialog('Password should be at least 6 characters');
      return false;
    }

    // Walidacja checkboxa przy rejestracji
    if (!isLogin && !termsAccepted) {
      _showErrorDialog('Please accept the terms & conditions');
      return false;
    }

    return true;
  }

  // ================= TERMS =================

  Future<void> _showTermsContentDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Conditions'),
        content: const SingleChildScrollView(
          child: Text(
            'FULL VERSION OF TERMS & CONDITIONS...',
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

  // ================= ERROR DIALOG =================

  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Validation Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ================= SUBMIT =================

  Future<void> submit() async {
    // Walidacja przed wysłaniem do Firebase
    if (!_validateInputs()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      if (isLogin) {
        // ===== LOGIN =====
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        // AuthProvider automatycznie wykryje zmianę i przejdzie do GetStarted
        // Nie trzeba ręcznie nawigować!

      } else {
        // ===== REGISTER =====
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final uid = userCredential.user?.uid;
        if (uid != null) {
          // Zapisujemy użytkownika w Firestore (AuthProvider też to robi, ale lepiej mieć backup)
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .set({
            'email': email,
            'accepted_terms_at': DateTime.now().toIso8601String(),
          }, SetOptions(merge: true));
        }

        // 🔑 ZMIANA: NIE WYLOGOWUJEMY PO REJESTRACJI
        // Pozostajemy zalogowani i AuthProvider automatycznie przejdzie do GetStarted
        
        // Pokaż komunikat o sukcesie
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
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

      if (!mounted) return; // Dodane: sprawdzenie czy widget jest zamontowany
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
      if (!mounted) return; // Dodane: sprawdzenie czy widget jest zamontowany
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ================= UI =================

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
                      enabled: (isLogin || termsAccepted) && !_isLoading,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      enabled: (isLogin || termsAccepted) && !_isLoading,
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
                            onChanged: _isLoading
                                ? null
                                : (val) {
                                    setState(() {
                                      termsAccepted = val ?? false;
                                    });
                                  },
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: _isLoading
                                  ? null
                                  : _showTermsContentDialog,
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
                      onPressed: (_isLoading ||
                              (!isLogin && !termsAccepted))
                          ? null
                          : submit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(isLogin ? 'Login' : 'Register'),
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : toggleForm,
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