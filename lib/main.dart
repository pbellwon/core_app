// lib/main.dart - LOGIKA POPRAWIONA + HOVER / PRESSED BUTTON COLOR
import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
// (usunięto importy webowe)
// Removed conditional import for dart.library.html
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'get_started.dart';
import 'welcome_page.dart';
import 'about_page.dart';
import 'help_page.dart';
import 'settings_page.dart';
import 'client_profile_quiz.dart';
import 'quiz_results.dart';
import 'explore_my_options.dart';
import 'help_me_reconnect.dart';
import 'my_favourites.dart';
import 'providers/auth_provider.dart';
import 'providers/menu_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // (usunięto rejestrację iframe)
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = (details) {
    debugPrint('FLUTTER ERROR: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFFBF3F9);
    const accentColor = Color(0xFFB31288);
    const headingTextColor = Color(0xFF860E66);

    const hoverPressedColor = Color(0xFFFF854D); // 🔥 TWÓJ KOLOR

    final theme = ThemeData(
      useMaterial3: false,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: headingTextColor,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: headingTextColor,
        secondary: accentColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: headingTextColor,
        elevation: 0,
      ),

      // 🔥 ELEVATED BUTTON
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (states) {
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.pressed)) {
                return hoverPressedColor;
              }
              return accentColor;
            },
          ),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),

      // 🔥 TEXT BUTTON
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith<Color>(
            (states) {
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.pressed)) {
                return hoverPressedColor;
              }
              return headingTextColor;
            },
          ),
        ),
      ),

      // 🔥 OUTLINED BUTTON
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith<Color>(
            (states) {
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.pressed)) {
                return hoverPressedColor;
              }
              return headingTextColor;
            },
          ),
          side: WidgetStateProperty.resolveWith<BorderSide>(
            (states) {
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.pressed)) {
                return const BorderSide(color: hoverPressedColor);
              }
              return BorderSide(color: headingTextColor);
            },
          ),
        ),
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppAuthProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: theme,
        initialRoute: '/',
        routes: {
          '/': (_) => const RootPage(),
          '/welcome': (_) => const WelcomePage(),
          '/login': (_) => const LoginPage(),
          '/settings': (_) => const SettingsPage(),
          '/profile': (_) => const ProfilePage(),
          '/help': (_) => const HelpPage(),
          '/about': (_) => const AboutPage(),
          '/get_started': (_) => const GetStartedPage(),
          '/client_quiz': (_) => const ClientProfileQuizPage(),
          '/quiz_results': (_) => const QuizResultsPage(),
          '/explore_my_options': (_) => const ExploreMyOptionsPage(),
          '/help_me_reconnect': (_) => const HelpMeReconnectPage(),
          '/my_favourites': (_) => const MyFavouritesPage(),
        },
        onUnknownRoute: (_) {
          return MaterialPageRoute(
            builder: (_) => const RootPage(),
          );
        },
      ),
    );
  }
}

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppAuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFB31288),
              ),
            ),
          );
        }

        if (!authProvider.isLoggedIn) {
          return const LoginPage();
        }

        return const WelcomePage();
      },
    );
  }
}