// lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// 🏷️ TYP wyliczeniowy dla ról użytkownika (do rozbudowy)
enum UserRole {
  user,     // zwykły użytkowni
  admin,    // administrator
  moderator // moderator
}

/// 📊 MODEL ODPOWIEDZI QUIZU
/// Przechowuje odpowiedź na jedno pytanie quizu
class QuizAnswer {
  final int questionId;
  final String answer;
  final DateTime answeredAt;

  const QuizAnswer({
    required this.questionId,
    required this.answer,
    required this.answeredAt,
  });

  /// 🔄 KONWERSJA NA MAP
  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'answer': answer,
      'answeredAt': answeredAt.toIso8601String(),
    };
  }

  /// 🔄 TWORZENIE Z MAP
  factory QuizAnswer.fromMap(Map<String, dynamic> map) {
    return QuizAnswer(
      questionId: map['questionId'] ?? 0,
      answer: map['answer'] ?? '',
      answeredAt: DateTime.parse(map['answeredAt']),
    );
  }
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
  final String? country;       // Kraj użytkownika (do rozbudowy)
  final String? timezone;      // Strefa czasowa użytkownika (do rozbudowy)
  final String? phoneNumber;   // Numer telefonu
  final String? photoURL;      // URL do zdjęcia profilowego
  final DateTime? updatedAt;   // Data ostatniej aktualizacji
  final UserRole role;         // Rola użytkownika
  final List<QuizAnswer>? quizAnswers; // Odpowiedzi na quiz profilowy
  final List<String>? favouriteVideos; // Lista ulubionych videoId

  /// 🏗️ KONSTRUKTOR
  AppUser({
    required this.uid,
    required this.email,
    required this.createdAt,
    this.displayName,
    this.dateOfBirth,
    this.country,
    this.timezone,
    this.phoneNumber,
    this.photoURL,
    this.updatedAt,
    this.role = UserRole.user, // Domyślnie zwykły użytkownik
    this.quizAnswers,
    this.favouriteVideos,
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
      if (country != null) 'country': country,
      if (timezone != null) 'timezone': timezone,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (photoURL != null) 'photoURL': photoURL,
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (quizAnswers != null && quizAnswers!.isNotEmpty)
        'quizAnswers': quizAnswers!.map((answer) => answer.toMap()).toList(),
      if (favouriteVideos != null && favouriteVideos!.isNotEmpty)
        'favouriteVideos': favouriteVideos,
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

    // 🔍 Parsowanie odpowiedzi quizu
    List<QuizAnswer>? parseQuizAnswers(List<dynamic>? answersList) {
      if (answersList == null || answersList.isEmpty) return null;
      
      try {
        return answersList.map((answerData) {
          if (answerData is Map<String, dynamic>) {
            return QuizAnswer.fromMap(answerData);
          }
          return QuizAnswer(
            questionId: 0,
            answer: '',
            answeredAt: DateTime.now(),
          );
        }).toList();
      } catch (e) {
        debugPrint('⚠️ Error parsing quiz answers: $e');
        return null;
      }
    }
    
    return AppUser(
      uid: data['uid'] ?? doc.id, // Używamy doc.id jeśli uid brak
      email: data['email'] ?? '',
      displayName: data['displayName'],
      dateOfBirth: parseDate(data['dateOfBirth']),
      country: data['country'],               // nowe pole
      timezone: data['timezone'],             // nowe pole
      phoneNumber: data['phoneNumber'],
      photoURL: data['photoURL'],
      createdAt: parseDate(data['createdAt']) ?? DateTime.now(),
      updatedAt: parseDate(data['updatedAt']),
      role: parseRole(data['role']),
      quizAnswers: parseQuizAnswers(data['quizAnswers']),
      favouriteVideos: (data['favouriteVideos'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  /// 🎯 POBRANIE ODPOWIEDZI NA PYTANIE
  /// Zwraca odpowiedź na konkretne pytanie lub null jeśli nie odpowiedziano
  String? getAnswerForQuestion(int questionId) {
    if (quizAnswers == null || quizAnswers!.isEmpty) return null;
    
    final answer = quizAnswers!.firstWhere(
      (answer) => answer.questionId == questionId,
      orElse: () => QuizAnswer(questionId: 0, answer: '', answeredAt: DateTime.now()),
    );
    
    return answer.questionId == questionId ? answer.answer : null;
  }

  /// 🎯 DODANIE/LUB ZAKTUALIZOWANIE ODPOWIEDZI
  /// Zwraca nowy obiekt użytkownika z zaktualizowaną odpowiedzią
  AppUser withQuizAnswer(QuizAnswer newAnswer) {
    final currentAnswers = quizAnswers ?? [];
    
    // Usuń starą odpowiedź na to pytanie jeśli istnieje
    final filteredAnswers = currentAnswers.where(
      (answer) => answer.questionId != newAnswer.questionId
    ).toList();
    
    // Dodaj nową odpowiedź
    final updatedAnswers = [...filteredAnswers, newAnswer];
    
    return copyWith(quizAnswers: updatedAnswers);
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
    return 'AppUser(uid: $uid, email: $email, displayName: $displayName, age: $age, quizAnswers: ${quizAnswers?.length ?? 0})';
  }

  /// 🔄 KOPIOWANIE Z AKTUALIZACJĄ
  /// Tworzy kopię użytkownika z możliwością aktualizacji pól
  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    DateTime? dateOfBirth,
    String? country,
    String? timezone,
    String? phoneNumber,
    String? photoURL,
    DateTime? updatedAt,
    UserRole? role,
    List<QuizAnswer>? quizAnswers,
    List<String>? favouriteVideos,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      createdAt: createdAt,
      displayName: displayName ?? this.displayName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      country: country ?? this.country,
      timezone: timezone ?? this.timezone,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoURL: photoURL ?? this.photoURL,
      updatedAt: updatedAt ?? this.updatedAt,
      role: role ?? this.role,
      quizAnswers: quizAnswers ?? this.quizAnswers,
      favouriteVideos: favouriteVideos ?? this.favouriteVideos,
    );
  }
}