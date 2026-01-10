// lib/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AppAuthProvider with ChangeNotifier {
  // 👤 AKTUALNY UŻYTKOWNIK (nasz AppUser model)
  AppUser? _currentUser;
  
  // ⏳ STAN ŁADOWANIA
  bool _isLoading = true;
  
  // 🔥 UŻYTKOWNIK FIREBASE AUTH
  User? _firebaseUser;
  
  // 📊 GETTERY
  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  User? get firebaseUser => _firebaseUser;

  /// 🏗️ KONSTRUKTOR - inicjalizacja listenera auth
  AppAuthProvider() {
    print('🆕 AppAuthProvider created');
    _initAuthListener();
  }

  /// 👂 INICJALIZACJA LISTENERA AUTORYZACJI
  void _initAuthListener() {
    print('👂 Setting up auth state listener');
    
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      print('🔄 Auth state changed: ${user?.email ?? "null"}');
      _firebaseUser = user;
      
      if (user == null) {
        // ❌ UŻYTKOWNIK WYLOGOWANY
        print('👤 User logged out');
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // ✅ UŻYTKOWNIK ZALOGOWANY
      print('👤 User logged in: ${user.email}, UID: ${user.uid}');
      _isLoading = true;
      notifyListeners();
      
      try {
        // 🔍 SPRAWDŹ CZY UŻYTKOWNIK MA DANE W FIRESTORE
        print('🔍 Checking Firestore for user: ${user.uid}');
        
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        print('📄 Firestore document exists: ${userDoc.exists}');
        
        if (userDoc.exists) {
          // 📥 UŻYTKOWNIK ISTNIEJE - WCZYTAJ DANE Z FIRESTORE
          print('📥 Loading user from Firestore...');
          _currentUser = AppUser.fromFirestore(userDoc);
          print('✅ User loaded: ${_currentUser!.email}');
        } else {
          // 🆕 PIERWSZE LOGOWANIE - UTWÓRZ NOWEGO UŻYTKOWNIKA
          print('🆕 First login - creating new user profile');
          _currentUser = AppUser(
            uid: user.uid,
            email: user.email ?? '',
            createdAt: DateTime.now(),
            displayName: user.displayName,
            photoURL: user.photoURL,
            role: UserRole.user,
          );
          
          // 💾 ZAPISZ DO FIRESTORE
          await _createUserInFirestore(user);
          print('✅ New user created and saved to Firestore');
        }
      } catch (e) {
        // ❌ BŁĄD - UTWÓRZ TYMCZASOWEGO UŻYTKOWNIKA
        print('❌ Error loading user data: $e');
        _currentUser = AppUser(
          uid: user.uid,
          email: user.email ?? '',
          createdAt: DateTime.now(),
          role: UserRole.user,
        );
      }

      _isLoading = false;
      notifyListeners();
      print('✅ Auth provider updated');
    });
  }

  /// 💾 TWORZENIE UŻYTKOWNIKA W FIRESTORE (przy pierwszym logowaniu)
  Future<void> _createUserInFirestore(User firebaseUser) async {
    try {
      print('💾 Creating user in Firestore for UID: ${firebaseUser.uid}');
      
      final userData = _currentUser!.toMap();
      print('📋 User data to save: $userData');
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .set(userData);
          
      print('✅ User successfully saved to Firestore');
    } catch (e) {
      print('❌ Error creating user in Firestore: $e');
      rethrow;
    }
  }

  /// ✏️ AKTUALIZACJA PROFILU UŻYTKOWNIKA
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
    DateTime? dateOfBirth,
    String? phoneNumber,
  }) async {
    if (_currentUser == null || _firebaseUser == null) {
      print('❌ Cannot update profile: no user logged in');
      throw Exception('User is not logged in');
    }

    print('✏️ Updating profile for: ${_currentUser!.email}');
    _isLoading = true;
    notifyListeners();

    try {
      // 1️⃣ AKTUALIZUJ W FIREBASE AUTHENTICATION (tylko displayName i photoURL)
      if (displayName != null || photoURL != null) {
        print('🔄 Updating Firebase Auth profile...');
        await _firebaseUser!.updateProfile(
          displayName: displayName,
          photoURL: photoURL,
        );
        await _firebaseUser!.reload();
        _firebaseUser = FirebaseAuth.instance.currentUser;
        print('✅ Firebase Auth updated');
      }

      // 2️⃣ PRZYGOTUJ DANE DO AKTUALIZACJI W FIRESTORE
      final updateData = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      if (displayName != null) {
        updateData['displayName'] = displayName;
        print('📝 Setting displayName: $displayName');
      }
      
      if (photoURL != null) {
        updateData['photoURL'] = photoURL;
        print('🖼️ Setting photoURL: $photoURL');
      }

      if (dateOfBirth != null) {
        updateData['dateOfBirth'] = dateOfBirth.toIso8601String();
        print('📅 Setting dateOfBirth: ${dateOfBirth.toIso8601String()}');
      }

      if (phoneNumber != null) {
        updateData['phoneNumber'] = phoneNumber;
        print('📱 Setting phoneNumber: $phoneNumber');
      }

      // 3️⃣ ZAPISZ DO FIRESTORE
      print('💾 Saving to Firestore...');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update(updateData);
      print('✅ Firestore updated successfully');

      // 4️⃣ AKTUALIZUJ LOKALNY STAN
      _currentUser = _currentUser!.copyWith(
        displayName: displayName ?? _currentUser!.displayName,
        photoURL: photoURL ?? _currentUser!.photoURL,
        dateOfBirth: dateOfBirth ?? _currentUser!.dateOfBirth,
        phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
        updatedAt: DateTime.now(),
      );

      print('✅ Local user state updated');
      
    } catch (e) {
      print('❌ Error updating profile: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      print('✅ Profile update completed');
    }
  }

  /// 🚪 WYLOGOWANIE
  Future<void> signOut() async {
    print('🚪 Signing out user: ${_currentUser?.email}');
    try {
      await FirebaseAuth.instance.signOut();
      _currentUser = null;
      _firebaseUser = null;
      _isLoading = false; // ✅ WAŻNE: reset isLoading
      notifyListeners();
      print('✅ User signed out successfully');
    } catch (e) {
      print('❌ Error signing out: $e');
      rethrow;
    }
  }

  /// 📧 WYSYŁANIE WERYFIKACJI EMAIL
  Future<void> sendEmailVerification() async {
    if (_firebaseUser == null) {
      throw Exception('User is not logged in');
    }

    try {
      print('📧 Sending email verification to: ${_firebaseUser!.email}');
      await _firebaseUser!.sendEmailVerification();
      print('✅ Email verification sent');
    } catch (e) {
      print('❌ Error sending email verification: $e');
      rethrow;
    }
  }

  /// 🔐 WYSYŁANIE RESETU HASŁA
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      print('🔐 Sending password reset to: $email');
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent');
    } catch (e) {
      print('❌ Error sending password reset: $e');
      rethrow;
    }
  }

  /// 📝 AKCEPTACJA REGULAMINU (opcjonalne - jeśli potrzebujesz)
  Future<void> acceptTerms() async {
    if (_currentUser == null) {
      print('❌ Cannot accept terms: no user logged in');
      return;
    }

    print('📝 Accepting terms for: ${_currentUser!.email}');
    final now = DateTime.now();
    
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update({
            'updatedAt': now.toIso8601String(),
            'acceptedTermsAt': now.toIso8601String(),
          });

      _currentUser = _currentUser!.copyWith(
        updatedAt: now,
      );

      notifyListeners();
      print('✅ Terms accepted');
    } catch (e) {
      print('❌ Error accepting terms: $e');
      rethrow;
    }
  }

  /// 🗑️ USUWANIE KONTA
  Future<void> deleteAccount() async {
    if (_firebaseUser == null) {
      throw Exception('User is not logged in');
    }

    print('🗑️ Deleting account: ${_firebaseUser!.email}');
    
    try {
      final userId = _firebaseUser!.uid;
      
      // 1. USUŃ Z FIRESTORE
      print('🗑️ Deleting from Firestore...');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .delete();
      
      // 2. USUŃ Z FIREBASE AUTHENTICATION
      print('🗑️ Deleting from Firebase Auth...');
      await _firebaseUser!.delete();
      
      // 3. WYCZYŚĆ LOKALNY STAN
      _currentUser = null;
      _firebaseUser = null;
      
      notifyListeners();
      print('✅ Account deleted successfully');
    } catch (e) {
      print('❌ Error deleting account: $e');
      rethrow;
    }
  }

  /// 🔄 ODŚWIEŻANIE DANYCH UŻYTKOWNIKA Z FIRESTORE
  Future<void> refreshUserData() async {
    if (_firebaseUser == null) {
      print('❌ Cannot refresh: no user logged in');
      return;
    }

    print('🔄 Refreshing user data for: ${_firebaseUser!.email}');
    
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_firebaseUser!.uid)
          .get();

      if (userDoc.exists) {
        _currentUser = AppUser.fromFirestore(userDoc);
        print('✅ User data refreshed from Firestore');
      } else {
        print('⚠️ User document not found in Firestore');
        _currentUser = AppUser(
          uid: _firebaseUser!.uid,
          email: _firebaseUser!.email ?? '',
          createdAt: DateTime.now(),
          role: UserRole.user,
        );
      }
      
      notifyListeners();
    } catch (e) {
      print('❌ Error refreshing user data: $e');
    }
  }

  /// 📧 CZY EMAIL JEST ZWERYFIKOWANY
  bool get isEmailVerified {
    final verified = _firebaseUser?.emailVerified ?? false;
    print('📧 Email verified: $verified');
    return verified;
  }

  /// 🔄 ODSWIEŻ DANE FIREBASE AUTH
  Future<void> reloadFirebaseUser() async {
    if (_firebaseUser != null) {
      print('🔄 Reloading Firebase Auth user...');
      await _firebaseUser!.reload();
      _firebaseUser = FirebaseAuth.instance.currentUser;
      notifyListeners();
      print('✅ Firebase Auth user reloaded');
    }
  }

  /// 🐛 DEBUG: POKAŻ INFO O UŻYTKOWNIKU
  void debugUserInfo() {
    print('=== DEBUG USER INFO ===');
    print('Logged in: $isLoggedIn');
    print('Loading: $_isLoading');
    if (_currentUser != null) {
      print('UID: ${_currentUser!.uid}');
      print('Email: ${_currentUser!.email}');
      print('Display Name: ${_currentUser!.displayName ?? "Not set"}');
      print('Phone: ${_currentUser!.phoneNumber ?? "Not set"}');
      print('Date of Birth: ${_currentUser!.dateOfBirth ?? "Not set"}');
      print('Role: ${_currentUser!.role.name}');
    } else {
      print('No current user');
    }
    print('=======================');
  }
}