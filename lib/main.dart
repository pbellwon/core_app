// lib/main.dart - LOGIKA POPRAWIONA, UI BEZ ZMIAN
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'get_started.dart';
import 'providers/auth_provider.dart';
import 'providers/menu_provider.dart';
import 'widgets/main_app_bar.dart';
import 'widgets/app_drawer.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
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

        // ⬇️ ROOT JAKO JEDYNE ŹRÓDŁO PRAWDY
        initialRoute: '/',
        routes: {
          '/': (_) => const RootPage(),
          '/welcome': (_) => const WelcomePage(),
          '/login': (_) => const LoginPage(),
          '/settings': (_) => const SettingsPage(),
          '/profile': (_) => const ProfilePage(),
          '/help': (_) => const HelpPage(),
          '/about': (_) => const AboutPage(),
          '/get_started': (_) => const GetStartedPageWithAppBar(),
          '/dashboard': (_) => const AbCdPage(),
        },

        // ⬇️ KLUCZOWE: jeśli Flutter Web trafi na „zły” URL
        // (np. po logout z /profile), ZAWSZE wracamy do '/'
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

        // ❗ JEDYNE MIEJSCE DECYZJI
        if (!authProvider.isLoggedIn) {
          return const LoginPage();
        }

        return const GetStartedPageWithAppBar();
      },
    );
  }
}

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

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: "Welcome", showBackButton: true),
      body: const Center(
        child: Text(
          'Welcome Page',
          style: TextStyle(fontSize: 24, color: Color(0xFF860E66)),
        ),
      ),
    );
  }
}

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
