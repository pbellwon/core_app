// lib/main.dart - LOGIKA POPRAWIONA + HOVER / PRESSED BUTTON COLOR
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'get_started.dart';
import 'welcome_page.dart';
import 'onboarding_page.dart';
import 'about_page.dart';
import 'help_page.dart';
import 'share_feedback_page.dart';
import 'profile_and_settings_page.dart';
import 'client_profile_quiz.dart';
import 'quiz_results.dart';
import 'explore_my_options.dart';
import 'request_resource.dart';
import 'my_program_page.dart';
import 'my_favourites.dart';
import 'providers/auth_provider.dart';
import 'providers/menu_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
final KartraRouteObserver kartraRouteObserver = KartraRouteObserver();

// Read from the server (not the compiled bundle) so a stale cached bundle still detects a new deploy.
Future<String?> _fetchDeployedVersion() async {
  try {
    final url = Uri.parse(
      '${Uri.base.origin}/version.json?t=${DateTime.now().millisecondsSinceEpoch}',
    );
    final res = await http.get(url).timeout(const Duration(seconds: 3));
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return '${data['version']}+${data['build_number']}';
  } catch (e) {
    debugPrint('⚠️ Could not fetch deployed version: $e');
    return null;
  }
}

/// Clears the persisted Firebase session when a new version has been deployed.
Future<void> _checkAppVersionOnStartup() async {
  try {
    final deployed = await _fetchDeployedVersion();
    if (deployed == null) return;

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('app_version');
    debugPrint('📱 Version check: deployed=$deployed, stored=$stored');

    if (stored != null && stored != deployed) {
      debugPrint('🔄 New deploy detected - clearing session');
      html.window.localStorage.clear();
      html.window.sessionStorage.clear();
      try {
        await html.window.indexedDB!
            .deleteDatabase('firebaseLocalStorageDb')
            .timeout(const Duration(seconds: 2));
      } catch (e) {
        debugPrint('⚠️ Could not delete IndexedDB: $e');
      }
    }
    await prefs.setString('app_version', deployed);
  } catch (e) {
    debugPrint('⚠️ Error checking version on startup: $e');
  }
}

void main() async {
  // (usunięto rejestrację iframe)
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🔄 Check version BEFORE Firebase init to clear old session
  await _checkAppVersionOnStartup();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = (details) {
    debugPrint('FLUTTER ERROR: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  runApp(const MyApp());
}

class KartraRouteObserver extends NavigatorObserver {
  void _update(Route<dynamic> route) {
    if (!kIsWeb) return;
    // ignore: avoid_web_libraries_in_flutter, deprecated_member_use
    final el = html.document.getElementById('kartra_live_chat');
    if (el == null) return;
    final routeName = route.settings.name;
    el.style.display = (routeName == '/help') ? '' : 'none';
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _update(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _update(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _update(newRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _update(previousRoute);
  }
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
        navigatorObservers: [routeObserver, kartraRouteObserver],
        theme: theme,
        initialRoute: '/',
        routes: {
          '/': (_) => const RootPage(),
          '/welcome': (_) => const WelcomePage(),
          '/login': (_) => const LoginPage(),
          '/share_feedback': (_) => const ShareFeedbackPage(),
          '/profile': (_) => const ProfileAndSettingsPage(),
          '/help': (_) => const HelpPage(),
          '/about': (_) => const AboutPage(),
          '/get_started': (_) => const GetStartedPage(),
          '/client_quiz': (_) => const ClientProfileQuizPage(),
          '/quiz_results': (_) => const QuizResultsPage(),
          '/explore_my_options': (_) => const ExploreMyOptionsPage(),
          '/request_resource': (_) => const RequestResourcePage(),
          '/my_program': (_) => const MyProgramPage(),
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

        // Check if user has completed onboarding
        final hasCompletedOnboarding = authProvider.currentUser?.onboardingCompleted ?? false;
        
        if (!hasCompletedOnboarding) {
          return const OnboardingPage();
        }

        return const WelcomePage();
      },
    );
  }
}