import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AppAuthProvider with ChangeNotifier {

    /// 💾 ZAPISZ WSZYSTKIE ODPOWIEDZI QUIZU DO FIRESTORE
    Future<void> saveAllQuizAnswers(List<QuizAnswer> answers) async {
      if (_currentUser == null || _firebaseUser == null) {
        debugPrint('❌ Cannot save quiz answers: no user logged in');
        throw Exception('User is not logged in');
      }
      try {
        // Aktualizuj lokalnie
        _currentUser = _currentUser!.copyWith(quizAnswers: answers);
        notifyListeners();

        // Przygotuj dane do zapisu
        final updateData = {
          'quizAnswers': answers.map((a) => a.toMap()).toList(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .update(updateData);
        debugPrint('✅ Quiz answers saved to Firestore');
      } catch (e) {
        debugPrint('❌ Error saving quiz answers: $e');
        rethrow;
      }
    }
  AppUser? _currentUser;
  User? _firebaseUser;
  bool _isLoading = false;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _firebaseUser != null;

  AppAuthProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      _firebaseUser = user;
      if (user == null) {
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
        return;
      }
      _isLoading = true;
      notifyListeners();
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          _currentUser = AppUser.fromFirestore(userDoc);
        } else {
          _currentUser = AppUser(
            uid: user.uid,
            email: user.email ?? '',
            createdAt: DateTime.now(),
            displayName: user.displayName,
            photoURL: user.photoURL,
            role: UserRole.user,
          );
          await _createUserInFirestore(user);
        }
      } catch (e) {
        _currentUser = AppUser(
          uid: user.uid,
          email: user.email ?? '',
          createdAt: DateTime.now(),
          role: UserRole.user,
        );
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _createUserInFirestore(User user) async {
    final newUser = AppUser(
      uid: user.uid,
      email: user.email ?? '',
      createdAt: DateTime.now(),
      displayName: user.displayName,
      photoURL: user.photoURL,
      role: UserRole.user,
    );
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(newUser.toMap());
  }

  // ⭐ DODAJ/USUŃ ULUBIONY FILM
  Future<void> toggleFavouriteVideo(String videoId) async {
    if (_currentUser == null || _firebaseUser == null) {
      debugPrint('❌ Cannot update favourites: no user logged in');
      throw Exception('User is not logged in');
    }
    final currentFavs = List<String>.from(_currentUser!.favouriteVideos ?? []);
    bool isFav = currentFavs.contains(videoId);
    if (isFav) {
      currentFavs.remove(videoId);
    } else {
      currentFavs.add(videoId);
    }
    _currentUser = _currentUser!.copyWith(favouriteVideos: currentFavs);
    notifyListeners();
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update({'favouriteVideos': currentFavs});
      debugPrint('⭐ Favourites updated in Firestore');
    } catch (e) {
      debugPrint('❌ Error updating favourites: $e');
    }
  }

  // ⭐ SPRAWDŹ, CZY FILM JEST ULUBIONY
  bool isFavourite(String videoId) {
    return _currentUser?.favouriteVideos?.contains(videoId) ?? false;
  }

  /// ✏️ AKTUALIZACJA PROFILU UŻYTKOWNIKA
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
    DateTime? dateOfBirth,
    String? phoneNumber,
    String? country,        // nowe pole
    String? timezone,       // nowe pole
  }) async {
    if (_currentUser == null || _firebaseUser == null) {
      debugPrint('❌ Cannot update profile: no user logged in');
      throw Exception('User is not logged in');
    }

    debugPrint('✏️ Updating profile for: \\${_currentUser!.email}');
    _isLoading = true;
    notifyListeners();

    try {
      // 1️⃣ AKTUALIZUJ W FIREBASE AUTHENTICATION (tylko displayName i photoURL)
      if (displayName != null || photoURL != null) {
        debugPrint('🔄 Updating Firebase Auth profile...');
        await _firebaseUser!.updateProfile(
          displayName: displayName,
          photoURL: photoURL,
        );
        await _firebaseUser!.reload();
        _firebaseUser = FirebaseAuth.instance.currentUser;
        debugPrint('✅ Firebase Auth updated');
      }

      // 2️⃣ PRZYGOTUJ DANE DO AKTUALIZACJI W FIRESTORE
      final updateData = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      if (displayName != null) {
        updateData['displayName'] = displayName;
        debugPrint('📝 Setting displayName: \\$displayName');
      }
      
      if (photoURL != null) {
        updateData['photoURL'] = photoURL;
        debugPrint('🖼️ Setting photoURL: \\$photoURL');
      }

      if (dateOfBirth != null) {
        updateData['dateOfBirth'] = dateOfBirth.toIso8601String();
        debugPrint('📅 Setting dateOfBirth: \\${dateOfBirth.toIso8601String()}');
      }

      if (phoneNumber != null) {
        updateData['phoneNumber'] = phoneNumber;
        debugPrint('📱 Setting phoneNumber: \\$phoneNumber');
      }

      if (country != null) {
        updateData['country'] = country;
        debugPrint('🌍 Setting country: \\$country');
      }

      if (timezone != null) {
        updateData['timezone'] = timezone;
        debugPrint('🕒 Setting timezone: \\$timezone');
      }

      // 3️⃣ ZAPISZ DO FIRESTORE
      debugPrint('💾 Saving to Firestore...');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update(updateData);
      debugPrint('✅ Firestore updated successfully');

      // 4️⃣ AKTUALIZUJ LOKALNY STAN
      _currentUser = _currentUser!.copyWith(
        displayName: displayName ?? _currentUser!.displayName,
        photoURL: photoURL ?? _currentUser!.photoURL,
        dateOfBirth: dateOfBirth ?? _currentUser!.dateOfBirth,
        phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
        country: country ?? _currentUser!.country,          // nowe
        timezone: timezone ?? _currentUser!.timezone,       // nowe
        updatedAt: DateTime.now(),
      );

      debugPrint('✅ Local user state updated');
      
    } catch (e) {
      debugPrint('❌ Error updating profile: \\$e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('✅ Profile update completed');
    }
  }

  /// 🚪 WYLOGOWANIE
  Future<void> signOut() async {
    debugPrint('🚪 Signing out user: \\${_currentUser?.email}');
    try {
      await FirebaseAuth.instance.signOut();
      _currentUser = null;
      _firebaseUser = null;
      _isLoading = false; // ✅ WAŻNE: reset isLoading
      notifyListeners();
      debugPrint('✅ User signed out successfully');
    } catch (e) {
      debugPrint('❌ Error signing out: \\$e');
      rethrow;
    }
  }

  /// 📧 WYSYŁANIE WERYFIKACJI EMAIL
  Future<void> sendEmailVerification() async {
    if (_firebaseUser == null) {
      throw Exception('User is not logged in');
    }

    try {
      debugPrint('📧 Sending email verification to: \\${_firebaseUser!.email}');
      await _firebaseUser!.sendEmailVerification();
      debugPrint('✅ Email verification sent');
    } catch (e) {
      debugPrint('❌ Error sending email verification: \\$e');
      rethrow;
    }
  }

  /// 🔐 WYSYŁANIE RESETU HASŁA
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      debugPrint('🔐 Sending password reset to: \\$email');
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      debugPrint('✅ Password reset email sent');
    } catch (e) {
      debugPrint('❌ Error sending password reset: \\$e');
      rethrow;
    }
  }

  /// 📝 AKCEPTACJA REGULAMINU (opcjonalne - jeśli potrzebujesz)
  Future<void> acceptTerms() async {
    if (_currentUser == null) {
      debugPrint('❌ Cannot accept terms: no user logged in');
      return;
    }

    debugPrint('📝 Accepting terms for: \\${_currentUser!.email}');
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
      debugPrint('✅ Terms accepted');
    } catch (e) {
      debugPrint('❌ Error accepting terms: \\$e');
      rethrow;
    }
  }

  /// 🗑️ USUWANIE KONTA
  Future<void> deleteAccount() async {
    if (_firebaseUser == null) {
      throw Exception('User is not logged in');
    }

    debugPrint('🗑️ Deleting account: \\${_firebaseUser!.email}');
    
    try {
      final userId = _firebaseUser!.uid;
      
      // 1. USUŃ Z FIRESTORE
      debugPrint('🗑️ Deleting from Firestore...');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .delete();
      
      // 2. USUŃ Z FIREBASE AUTHENTICATION
      debugPrint('🗑️ Deleting from Firebase Auth...');
      await _firebaseUser!.delete();
      
      // 3. WYCZYŚĆ LOKALNY STAN
      _currentUser = null;
      _firebaseUser = null;
      
      notifyListeners();
      debugPrint('✅ Account deleted successfully');
    } catch (e) {
      debugPrint('❌ Error deleting account: \\$e');
      rethrow;
    }
  }

  /// 🔄 ODŚWIEŻANIE DANYCH UŻYTKOWNIKA Z FIRESTORE
  Future<void> refreshUserData() async {
    if (_firebaseUser == null) {
      debugPrint('❌ Cannot refresh: no user logged in');
      return;
    }

    debugPrint('🔄 Refreshing user data for: \\${_firebaseUser!.email}');
    
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_firebaseUser!.uid)
          .get();

      if (userDoc.exists) {
        _currentUser = AppUser.fromFirestore(userDoc);
        debugPrint('✅ User data refreshed from Firestore');
      } else {
        debugPrint('⚠️ User document not found in Firestore');
        _currentUser = AppUser(
          uid: _firebaseUser!.uid,
          email: _firebaseUser!.email ?? '',
          createdAt: DateTime.now(),
          role: UserRole.user,
        );
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error refreshing user data: \\$e');
    }
  }

  /// 📧 CZY EMAIL JEST ZWERYFIKOWANY
  bool get isEmailVerified {
    final verified = _firebaseUser?.emailVerified ?? false;
    debugPrint('📧 Email verified: \\$verified');
    return verified;
  }

  /// 🔄 ODSWIEŻ DANE FIREBASE AUTH
  Future<void> reloadFirebaseUser() async {
    if (_firebaseUser != null) {
      debugPrint('🔄 Reloading Firebase Auth user...');
      await _firebaseUser!.reload();
      _firebaseUser = FirebaseAuth.instance.currentUser;
      notifyListeners();
      debugPrint('✅ Firebase Auth user reloaded');
    }
  }

  /// 🐛 DEBUG: POKAŻ INFO O UŻYTKOWNIKU
  void debugUserInfo() {
    debugPrint('=== DEBUG USER INFO ===');
    debugPrint('Logged in: \\$isLoggedIn');
    debugPrint('Loading: \\$_isLoading');
    if (_currentUser != null) {
      debugPrint('UID: \\${_currentUser!.uid}');
      debugPrint('Email: \\${_currentUser!.email}');
      debugPrint('Display Name: \\${_currentUser!.displayName ?? "Not set"}');
      debugPrint('Phone: \\${_currentUser!.phoneNumber ?? "Not set"}');
      debugPrint('Date of Birth: \\${_currentUser!.dateOfBirth ?? "Not set"}');
      debugPrint('Country: \\${_currentUser!.country ?? "Not set"}');
      debugPrint('Timezone: \\${_currentUser!.timezone ?? "Not set"}');
      debugPrint('Role: \\${_currentUser!.role.name}');
      debugPrint('Quiz Answers: \\${_currentUser!.quizAnswers?.length ?? 0}');
    } else {
      debugPrint('No current user');
    }
    debugPrint('=======================');
  }


  // (usunięto zduplikowane metody i gettery)
}