// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AppAuthProvider with ChangeNotifier {
  AppUser? _currentUser;
  bool _isLoading = true;
  User? _firebaseUser;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  AppAuthProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _firebaseUser = user;
      
      if (user == null) {
        // Użytkownik wylogowany
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      try {
        // Sprawdź czy użytkownik ma dane w Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final userData = userDoc.data();
        
        if (userDoc.exists && userData != null) {
          // Użytkownik istnieje w Firestore - pobierz pełne dane
          _currentUser = AppUser.fromFirebaseUser(
            userData, 
            user.email, 
            user.uid
          );
        } else {
          // Pierwsze logowanie - utwórz podstawowego użytkownika
          _currentUser = AppUser.fromFirebaseUser(
            null, 
            user.email, 
            user.uid
          );
          
          // Automatycznie zapisz użytkownika do Firestore przy pierwszym logowaniu
          await _createUserInFirestore(user);
        }
      } catch (e) {
        // Błąd pobierania danych - utwórz tymczasowego użytkownika
        if (kDebugMode) {
          print('Błąd pobierania danych użytkownika: $e');
        }
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

  Future<void> _createUserInFirestore(User firebaseUser) async {
    try {
      final now = DateTime.now().toIso8601String();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .set({
            'uid': firebaseUser.uid,
            'email': firebaseUser.email,
            'displayName': firebaseUser.displayName,
            'photoURL': firebaseUser.photoURL,
            'createdAt': now,
            'updatedAt': now,
          });
    } catch (e) {
      if (kDebugMode) {
        print('Błąd tworzenia użytkownika w Firestore: $e');
      }
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      _currentUser = null;
      _firebaseUser = null;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Błąd wylogowania: $e');
      }
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    if (_currentUser == null || _firebaseUser == null) {
      throw Exception('Użytkownik nie jest zalogowany');
    }

    try {
      // 1. Aktualizuj w Firebase Authentication
      await _firebaseUser!.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      // 2. Odśwież obiekt Firebase User (ważne!)
      await _firebaseUser!.reload();
      _firebaseUser = FirebaseAuth.instance.currentUser;

      // 3. Aktualizuj w Firestore
      final updateData = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      if (displayName != null) {
        updateData['displayName'] = displayName;
      }
      
      if (photoURL != null) {
        updateData['photoURL'] = photoURL;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update(updateData);

      // 4. Aktualizuj lokalny stan
      _currentUser = AppUser(
        uid: _currentUser!.uid,
        email: _firebaseUser!.email ?? _currentUser!.email,
        displayName: displayName ?? _currentUser!.displayName,
        photoURL: photoURL ?? _currentUser!.photoURL,
        acceptedTermsAt: _currentUser!.acceptedTermsAt,
      );

      // 5. Odśwież UI
      notifyListeners();
      
    } catch (e) {
      if (kDebugMode) {
        print('Błąd aktualizacji profilu: $e');
      }
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    if (_firebaseUser == null) {
      throw Exception('Użytkownik nie jest zalogowany');
    }

    try {
      await _firebaseUser!.sendEmailVerification();
    } catch (e) {
      if (kDebugMode) {
        print('Błąd wysyłania weryfikacji email: $e');
      }
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      if (kDebugMode) {
        print('Błąd wysyłania resetu hasła: $e');
      }
      rethrow;
    }
  }

  Future<void> acceptTerms() async {
    if (_currentUser == null) return;

    final now = DateTime.now();
    
    try {
      // 1. Aktualizuj w Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update({
            'accepted_terms_at': now.toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          });

      // 2. Aktualizuj lokalnie
      _currentUser = AppUser(
        uid: _currentUser!.uid,
        email: _currentUser!.email,
        displayName: _currentUser!.displayName,
        photoURL: _currentUser!.photoURL,
        acceptedTermsAt: now,
      );

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Błąd akceptacji regulaminu: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    if (_firebaseUser == null) {
      throw Exception('Użytkownik nie jest zalogowany');
    }

    try {
      final userId = _firebaseUser!.uid;
      
      // 1. Usuń z Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .delete();
      
      // 2. Usuń z Firebase Authentication
      await _firebaseUser!.delete();
      
      // 3. Wyczyść lokalny stan
      _currentUser = null;
      _firebaseUser = null;
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Błąd usuwania konta: $e');
      }
      rethrow;
    }
  }

  // Metoda pomocnicza do odświeżania danych użytkownika
  Future<void> refreshUserData() async {
    if (_firebaseUser == null) return;

    try {
      // Ponownie pobierz dane z Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_firebaseUser!.uid)
          .get();

      final userData = userDoc.data();
      
      if (userDoc.exists && userData != null) {
        _currentUser = AppUser.fromFirebaseUser(
          userData, 
          _firebaseUser!.email, 
          _firebaseUser!.uid
        );
      } else {
        _currentUser = AppUser.fromFirebaseUser(
          null, 
          _firebaseUser!.email, 
          _firebaseUser!.uid
        );
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Błąd odświeżania danych użytkownika: $e');
      }
    }
  }

  // Sprawdź czy email jest zweryfikowany
  bool get isEmailVerified {
    return _firebaseUser?.emailVerified ?? false;
  }

  // Pobierz świeże dane z Firebase Auth
  Future<void> reloadFirebaseUser() async {
    if (_firebaseUser != null) {
      await _firebaseUser!.reload();
      _firebaseUser = FirebaseAuth.instance.currentUser;
      notifyListeners();
    }
  }
}