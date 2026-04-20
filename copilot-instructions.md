# Copilot Instructions

## Cel projektu
Aplikacja Flutter z obsługą Firebase, stronami quizu, profilem użytkownika, menu bocznym oraz routingiem. Projekt korzysta z Provider do zarządzania stanem i posiada rozbudowaną strukturę stron.

## Najważniejsze pliki i foldery
- `lib/main.dart` – punkt wejścia, routing, konfiguracja theme, Provider
- `lib/providers/` – Providerzy do zarządzania stanem (np. MenuProvider, AuthProvider)
- `lib/widgets/` – Komponenty UI, np. MainAppBar, MenuOverlay
- `lib/models/` – Modele danych (np. MenuItem, UserModel)
- `lib/get_started.dart`, `lib/welcome_page.dart`, `lib/help_me_reconnect.dart`, `lib/quiz_results.dart`, `lib/explore_my_options.dart` – Strony aplikacji
- `pubspec.yaml` – zależności projektu

## Routing
Wszystkie strony są rejestrowane w `routes` w `main.dart`. Przykład:
```dart
routes: {
  '/': (_) => const RootPage(),
  '/welcome': (_) => const WelcomePage(),
  '/get_started': (_) => const GetStartedPage(),
  '/quiz_results': (_) => const QuizResultsPage(),
  '/explore_my_options': (_) => const ExploreMyOptionsPage(),
  // ...
}
```

## Menu
- Menu po lewej stronie (hamburger) oraz po prawej (user profile) generowane są dynamicznie na podstawie `MenuProvider`.
- Pozycje menu definiowane są w `MenuProvider`.

## Firebase
- Konfiguracja w pliku `firebase_options.dart`.
- Obsługa logowania, rejestracji, quizu i profilu użytkownika.

## Testy
- Testy znajdują się w folderze `test/`.
- Do testowania używaj `flutter test`.

## Aktualizacja zależności
Aby zaktualizować zależności do najnowszych wersji:
```
flutter pub upgrade --major-versions
```

## Dobre praktyki
- Każda nowa strona powinna mieć własny plik w `lib/` i być dodana do routingu w `main.dart`.
- Komponenty UI umieszczaj w `lib/widgets/`.
- Stan aplikacji zarządzaj przez Provider.
- Unikaj duplikowania kodu – korzystaj z widgetów i providerów.

## Inne
- Plik `explore_my_options.dart` jest obecnie pustą stroną – możesz go rozwinąć według potrzeb.
- Plik `README_CUSTOM.md` możesz wykorzystać na własne notatki.

---

> Ten plik został wygenerowany automatycznie przez GitHub Copilot na podstawie struktury i kodu projektu.
