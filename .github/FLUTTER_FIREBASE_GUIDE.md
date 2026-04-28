
# Flutter & Firebase Integration Guide (Project-Specific)

Ten przewodnik opisuje szczegóły integracji Firebase w Twoim projekcie Flutter.

---

## Wymagania wstępne
- Flutter SDK (np. 3.41.2)
- Konto Firebase
- Skonfigurowany projekt Firebase (Android/iOS/Web)

## 1. Zależności w `pubspec.yaml`

W Twoim projekcie używane są:

```yaml
dependencies:
  firebase_core: ^4.2.1
  firebase_auth: ^6.1.2
  cloud_firestore: ^6.1.0
  # ...
```
Zainstaluj zależności:
```sh
flutter pub get
```

## 2. Pliki konfiguracyjne Firebase

- **Android:** `android/app/google-services.json`
- **iOS:** `ios/Runner/GoogleService-Info.plist`
- **Web:** konfiguracja w `lib/firebase_options.dart` (wygenerowany przez FlutterFire CLI)

## 3. Inicjalizacja Firebase

W pliku `lib/main.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
```

## 4. Obsługa użytkownika i autoryzacja

Logowanie, rejestracja i zarządzanie użytkownikiem realizowane są przez `firebase_auth` oraz `cloud_firestore`:

- Plik: `lib/providers/auth_provider.dart` – cała logika autoryzacji, rejestracji, aktualizacji profilu, usuwania konta, zapisu odpowiedzi do Firestore.
- Plik: `lib/login_page.dart` – UI logowania/rejestracji, zapisywanie użytkownika do Firestore po rejestracji.

Przykład rejestracji użytkownika:
```dart
UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
  email: email,
  password: password,
);
await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
  'email': email,
  'accepted_terms_at': DateTime.now().toIso8601String(),
});
```

## 5. Przechowywanie i aktualizacja danych użytkownika

- Dane użytkownika są przechowywane w kolekcji `users` w Firestore.
- Aktualizacja profilu i quizu: metody w `AuthProvider` aktualizują odpowiednie pola w dokumencie użytkownika.

Przykład zapisu odpowiedzi quizu:
```dart
await FirebaseFirestore.instance
    .collection('users')
    .doc(_currentUser!.uid)
    .update({
      'quizAnswers': answers.map((a) => a.toMap()).toList(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
```

## 6. Usuwanie konta

W `AuthProvider` usuwane są dane z Firestore i Firebase Auth:
```dart
await FirebaseFirestore.instance.collection('users').doc(userId).delete();
await _firebaseUser!.delete();
```

## 7. Testy

- Testy znajdują się w folderze `test/`.
- Uruchamianie testów: `flutter test`

## 8. CI/CD i hosting

- Workflow GitHub Actions: `.github/workflows/firebase-hosting-pull-request.yml` – automatyczne budowanie i deploy na Firebase Hosting dla PR na branchu `dev`.

## 9. Dodatkowe informacje

- Routing i strony: rejestrowane w `main.dart`.
- Zarządzanie stanem: Provider (`lib/providers/`)
- Modele danych: `lib/models/`
- Komponenty UI: `lib/widgets/`

## 10. Przydatne linki
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Flutter Documentation](https://docs.flutter.dev/)

---

Przewodnik został wygenerowany automatycznie na podstawie analizy kodu projektu. W razie zmian w strukturze projektu, zaktualizuj ten plik.
