// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  AppUser? _currentUser;
  bool _isLoading = true;
  User? _firebaseUser;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  AuthProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _firebaseUser = user;
      
      if (user == null) {
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      try {
        // Pobierz dodatkowe dane z Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final userData = userDoc.data();
        _currentUser = AppUser.fromFirebaseUser(
          userData, 
          user.email, 
          user.uid
        );
      } catch (e) {
        // Jeśli nie ma danych w Firestore, użyj tylko danych z Firebase Auth
        _currentUser = AppUser.fromFirebaseUser(
          null, 
          user.email, 
          user.uid
        );
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    _currentUser = null;
    _firebaseUser = null;
    notifyListeners();
  }

  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    if (_currentUser == null || _firebaseUser == null) return;

    // Update w Firebase Auth
    await _firebaseUser!.updateDisplayName(displayName);
    await _firebaseUser!.updatePhotoURL(photoURL);

    // Update w Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .update({
      'displayName': displayName,
      'photoURL': photoURL,
      'updatedAt': DateTime.now().toIso8601String(),
    });

    // Update lokalnie
    _currentUser = AppUser(
      uid: _currentUser!.uid,
      email: _currentUser!.email,
      displayName: displayName ?? _currentUser!.displayName,
      photoURL: photoURL ?? _currentUser!.photoURL,
      acceptedTermsAt: _currentUser!.acceptedTermsAt,
    );

    notifyListeners();
  }
}