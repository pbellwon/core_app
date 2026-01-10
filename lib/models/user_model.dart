// lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';


/// 🏷️ TYP wyliczeniowy dla ról użytkownika (do rozbudowy)
enum UserRole {
  user,     // zwykły użytkownik
  admin,    // administrator
  moderator // moderator
}

/// 👤 GŁÓWNA KLASA MODELU UŻYTKOWNIKA
/// Przechowuje wszystkie dane profilu użytkownika
class AppUser {
  // 🔐 WYMAGANE POLA (nie mogą być null)
  final String uid;          // Unikalny ID z Firebase Auth
  final String email;        // Email użytkownika
  final DateTime createdAt;  // Data utworzenia konta

  // 📝 OPCJONALNE POLA (mogą być null)
  final String? displayName;   // Wyświetlana nazwa użytkownika
  final DateTime? dateOfBirth; // Data urodzenia
  final String? phoneNumber;   // Numer telefonu
  final String? photoURL;      // URL do zdjęcia profilowego
  final DateTime? updatedAt;   // Data ostatniej aktualizacji
  final UserRole role;         // Rola użytkownika

  /// 🏗️ KONSTRUKTOR
  AppUser({
    required this.uid,
    required this.email,
    required this.createdAt,
    this.displayName,
    this.dateOfBirth,
    this.phoneNumber,
    this.photoURL,
    this.updatedAt,
    this.role = UserRole.user, // Domyślnie zwykły użytkownik
  });

  /// 🔄 KONWERSJA NA MAP (dla Firestore)
  /// Zamienia obiekt AppUser na `Map<String, dynamic>` do zapisu w bazie
  Map<String, dynamic> toMap() {
    return {
      // 🔐 Wymagane pola
      'uid': uid,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'role': role.name, // Zapisujemy nazwę enuma jako string
      
      // 📝 Opcjonalne pola (zapisujemy tylko jeśli nie są null)
      if (displayName != null) 'displayName': displayName,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth!.toIso8601String(),
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (photoURL != null) 'photoURL': photoURL,
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// 🔄 TWORZENIE Z DOCUMENT SNAPSHOT (z Firestore)
  /// Tworzy obiekt AppUser z danych pobranych z Firestore
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // 🔍 Parsowanie dat (ważne: mogą być null lub w złym formacie)
    DateTime? parseDate(String? dateString) {
      if (dateString == null || dateString.isEmpty) return null;
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        // Warunkowe logowanie tylko w trybie debug
        assert(() {
          debugPrint('⚠️ Error parsing date: $dateString');
          return true;
        }());
        return null;
      }
    }
    
    // 🔍 Parsowanie roli użytkownika
    UserRole parseRole(String? roleString) {
      if (roleString == null) return UserRole.user;
      try {
        return UserRole.values.firstWhere(
          (role) => role.name == roleString,
          orElse: () => UserRole.user,
        );
      } catch (e) {
        return UserRole.user;
      }
    }
    
    return AppUser(
      uid: data['uid'] ?? doc.id, // Używamy doc.id jeśli uid brak
      email: data['email'] ?? '',
      displayName: data['displayName'],
      dateOfBirth: parseDate(data['dateOfBirth']),
      phoneNumber: data['phoneNumber'],
      photoURL: data['photoURL'],
      createdAt: parseDate(data['createdAt']) ?? DateTime.now(),
      updatedAt: parseDate(data['updatedAt']),
      role: parseRole(data['role']),
    );
  }

  /// 🎂 OBLICZANIE WIEKU (getter)
  /// Automatycznie oblicza wiek na podstawie dateOfBirth
  int? get age {
    if (dateOfBirth == null) return null;
    
    final now = DateTime.now();
    int calculatedAge = now.year - dateOfBirth!.year;
    
    // Korekta jeśli urodziny w tym roku jeszcze nie były
    if (now.month < dateOfBirth!.month || 
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      calculatedAge--;
    }
    
    return calculatedAge;
  }

  /// 📅 FORMATOWANA DATA URODZENIA (getter)
  /// Zwraca sformatowaną datę lub pusty string
  String get formattedDateOfBirth {
    if (dateOfBirth == null) return 'Not set';
    return '${dateOfBirth!.day}/${dateOfBirth!.month}/${dateOfBirth!.year}';
  }

  /// 👤 INICJAŁY (getter)
  /// Zwraca inicjały do awatara
  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final parts = displayName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return displayName![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  /// 🔍 CZY JEST ADMINEM (getter)
  bool get isAdmin => role == UserRole.admin;
  
  /// 🔍 CZY JEST MODERATOREM (getter)
  bool get isModerator => role == UserRole.moderator;

  /// 📋 DEBUG STRING (dla konsoli)
  @override
  String toString() {
    return 'AppUser(uid: $uid, email: $email, displayName: $displayName, age: $age)';
  }

  /// 🔄 KOPIOWANIE Z AKTUALIZACJĄ
  /// Tworzy kopię użytkownika z możliwością aktualizacji pól
  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    DateTime? dateOfBirth,
    String? phoneNumber,
    String? photoURL,
    DateTime? updatedAt,
    UserRole? role,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      createdAt: createdAt,
      displayName: displayName ?? this.displayName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoURL: photoURL ?? this.photoURL,
      updatedAt: updatedAt ?? this.updatedAt,
      role: role ?? this.role,
    );
  }
}