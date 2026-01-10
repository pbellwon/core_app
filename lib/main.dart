// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'profile_page.dart'; // ✅ Importujemy PRAWDZIWY ProfilePage
import 'get_started.dart';
import 'providers/auth_provider.dart';
import 'providers/menu_provider.dart';
import 'welcome_page.dart';
import 'widgets/main_app_bar.dart';
import 'widgets/app_drawer.dart';

/// 🔑 Globalny navigatorKey dla MenuProvider (wylogowanie)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
    // 🌈 Kolory globalne
    const backgroundColor = Color(0xFFFBF3F9);
    const accentColor = Color(0xFFB31288);
    const headingTextColor = Color(0xFF860E66);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider(), lazy: false),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: ThemeData(
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
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: headingTextColor,
            ),
          ),
        ),
        home: const RootPage(),
        routes: {
          '/welcome': (_) => const WelcomePage(),
          '/login': (_) => const LoginPage(),
          '/settings': (_) => const SettingsPage(),
          '/profile': (_) => const ProfilePage(), // ✅ UŻYWA importowanego ProfilePage
          '/help': (_) => const HelpPage(),
          '/about': (_) => const AboutPage(),
          '/get_started': (_) => const GetStartedPageWithAppBar(),
          '/dashboard': (_) => const AbCdPage(),
        },
      ),
    );
  }
}

/// Strona sprawdzająca auth state
class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppAuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFB31288)),
            ),
          );
        }
        return authProvider.isLoggedIn
            ? const GetStartedPageWithAppBar()
            : const LoginPage();
      },
    );
  }
}

/// GetStartedPage z AppBar + Drawer
class GetStartedPageWithAppBar extends StatefulWidget {
  const GetStartedPageWithAppBar({super.key});

  @override
  State<GetStartedPageWithAppBar> createState() =>
      _GetStartedPageWithAppBarState();
}

class _GetStartedPageWithAppBarState extends State<GetStartedPageWithAppBar> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false)
          .setCurrentPage('get_started');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: "", showBackButton: false),
      drawer: const AppDrawer(),
      body: const GetStarted(),
    );
  }
}

/// Przykładowe strony - ZOSTAWIAMY TYLKO TE KTÓRE NIE MAJĄ OSOBNYCH PLIKÓW
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: "Settings", showBackButton: true),
      body: const Center(child: Text("Settings Page")),
    );
  }
}

// ❌ USUŃ TĘ KLASĘ - mamy ją w osobnym pliku!
// class ProfilePage extends StatelessWidget {
//   const ProfilePage({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const MainAppBar(title: "Profile", showBackButton: true),
//       body: const Center(child: Text("Profile Page")),
//     );
//   }
// }

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: "Help", showBackButton: true),
      body: const Center(child: Text("Help Page")),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: "About", showBackButton: true),
      body: const Center(child: Text("About Page")),
    );
  }
}

class AbCdPage extends StatefulWidget {
  const AbCdPage({super.key});

  @override
  State<AbCdPage> createState() => _AbCdPageState();
}

class _AbCdPageState extends State<AbCdPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false)
          .setCurrentPage('ab_cd');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: "AB CD Page", showBackButton: true),
      drawer: const AppDrawer(),
      body: const Center(child: Text("Strona AB CD")),
    );
  }
}