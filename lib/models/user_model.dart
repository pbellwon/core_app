// lib/models/user_model.dart
class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final DateTime? acceptedTermsAt;

  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.acceptedTermsAt,
  });

  factory AppUser.fromFirebaseUser(Map<String, dynamic>? firestoreData, String? email, String? uid) {
    return AppUser(
      uid: uid ?? '',
      email: email ?? '',
      displayName: firestoreData?['displayName'],
      photoURL: firestoreData?['photoURL'],
      acceptedTermsAt: firestoreData != null && firestoreData['accepted_terms_at'] != null
          ? DateTime.parse(firestoreData['accepted_terms_at'])
          : null,
    );
  }

  bool get isEmailVerified => true;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'acceptedTermsAt': acceptedTermsAt?.toIso8601String(),
    };
  }
}