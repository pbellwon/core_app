// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'get_started.dart';
import 'providers/auth_provider.dart';
import 'providers/menu_provider.dart';
import 'widgets/main_app_bar.dart';
import 'widgets/menu_overlay.dart';
import 'welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Dodaj globalne error handling
  FlutterError.onError = (details) {
    print('FLUTTER ERROR: ${details.exception}');
    print('Stack trace: ${details.stack}');
  };
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppAuthProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => MenuProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: false,
          scaffoldBackgroundColor: const Color(0xFFFBF3F9),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFBF3F9),
            foregroundColor: Color(0xFF860E66),
            elevation: 0,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFF860E66)),
            bodyMedium: TextStyle(color: Color(0xFF860E66)),
            bodySmall: TextStyle(color: Color(0xFF860E66)),
            displayLarge: TextStyle(color: Color(0xFF860E66)),
            displayMedium: TextStyle(color: Color(0xFF860E66)),
            displaySmall: TextStyle(color: Color(0xFF860E66)),
            headlineLarge: TextStyle(color: Color(0xFF860E66)),
            headlineMedium: TextStyle(color: Color(0xFF860E66)),
            headlineSmall: TextStyle(color: Color(0xFF860E66)),
            labelLarge: TextStyle(color: Color(0xFF860E66)),
            labelMedium: TextStyle(color: Color(0xFF860E66)),
            labelSmall: TextStyle(color: Color(0xFF860E66)),
            titleLarge: TextStyle(color: Color(0xFF860E66)),
            titleMedium: TextStyle(color: Color(0xFF860E66)),
            titleSmall: TextStyle(color: Color(0xFF860E66)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB31288),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFB31288),
            foregroundColor: Colors.white,
            hoverColor: Color(0xFFCC5500),
          ),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFB31288),
            secondary: Color(0xFF860E66),
            background: Color(0xFFFBF3F9),
            surface: Color(0xFFFBF3F9),
            error: Color(0xFFE53935),
          ),
        ),
        builder: (context, child) {
          return MenuOverlay(child: child!);
        },
        initialRoute: '/',
        routes: {
          '/': (context) {
            print('🚀 [MAIN] Navigating to RootPage');
            return const RootPage();
          },
          '/welcome': (context) {
            print('🚀 [MAIN] Navigating to WelcomePage');
            return const WelcomePage();
          },
          '/dashboard': (context) {
            print('🚀 [MAIN] Navigating to AbCdPage');
            return const AbCdPage();
          },
          '/settings': (context) {
            print('🚀 [MAIN] Navigating to SettingsPage');
            return const SettingsPage();
          },
          '/profile': (context) {
            print('🚀 [MAIN] Navigating to ProfilePage');
            return const ProfilePage();
          },
          '/help': (context) {
            print('🚀 [MAIN] Navigating to HelpPage');
            return const HelpPage();
          },
          '/about': (context) {
            print('🚀 [MAIN] Navigating to AboutPage');
            return const AboutPage();
          },
          '/login': (context) {
            print('🚀 [MAIN] Navigating to LoginPage');
            return const LoginPage();
          },
        },
        onGenerateRoute: (settings) {
          print('🔄 [MAIN] onGenerateRoute called for: ${settings.name}');
          if (settings.name == '/logout') {
            return null;
          }
          
          // Jeśli route nie istnieje, pokaż error page
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Page not found'),
                    Text('Route: ${settings.name}'),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go back'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        navigatorObservers: [_RouteObserver()],
        onUnknownRoute: (settings) {
          print('❌ [MAIN] onUnknownRoute called for: ${settings.name}');
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('404')),
              body: Center(child: Text('Unknown route: ${settings.name}')),
            ),
          );
        },
      ),
    );
  }
}

class _RouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('📍 [ROUTE] Pushed: ${route.settings.name} (from: ${previousRoute?.settings.name})');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('↩️ [ROUTE] Popped: ${route.settings.name} (back to: ${previousRoute?.settings.name})');
  }
}

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    print('📱 [RootPage] Building widget');
    return Consumer<AppAuthProvider>(
      builder: (context, authProvider, child) {
        print('🔐 [RootPage] Auth state: isLoading=${authProvider.isLoading}, isLoggedIn=${authProvider.isLoggedIn}');
        
        if (authProvider.isLoading) {
          return Scaffold(
            backgroundColor: const Color(0xFFFBF3F9),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFFB31288)),
                  const SizedBox(height: 20),
                  Text(
                    "Ładowanie...",
                    style: TextStyle(color: const Color(0xFF860E66)),
                  ),
                ],
              ),
            ),
          );
        }

        if (authProvider.isLoggedIn) {
          print('✅ [RootPage] User logged in, going to GetStartedPageWithAppBar');
          return const GetStartedPageWithAppBar();
        } else {
          print('🚫 [RootPage] User not logged in, going to LoginPage');
          return const LoginPage();
        }
      },
    );
  }
}

class GetStartedPageWithAppBar extends StatefulWidget {
  const GetStartedPageWithAppBar({super.key});

  @override
  State<GetStartedPageWithAppBar> createState() => _GetStartedPageWithAppBarState();
}

class _GetStartedPageWithAppBarState extends State<GetStartedPageWithAppBar> {
  @override
  void initState() {
    super.initState();
    print('🎬 [GetStartedPage] initState');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔄 [GetStartedPage] Setting currentPage to get_started');
      try {
        final menuProvider = Provider.of<MenuProvider>(context, listen: false);
        menuProvider.setCurrentPage('get_started');
        print('✅ [GetStartedPage] Current page set successfully');
        
        // Test: sprawdź jakie pageLinks są dostępne
        final pageLinks = menuProvider.pageLinks;
        print('📋 [GetStartedPage] Available pageLinks: ${pageLinks.length}');
        for (var link in pageLinks) {
          print('   - ${link.title}: ${link.route} (filter: ${link.pageFilter})');
        }
      } catch (e) {
        print('❌ [GetStartedPage] Error setting current page: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('📱 [GetStartedPage] Building widget');
    return Scaffold(
      appBar: MainAppBar(
        title: "Get Started",
        showBackButton: false,
      ),
      body: Column(
        children: [
          Expanded(child: GetStarted()),
          // DODAJEMY TEST BUTTON
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                print('🧪 [TEST] Direct navigation to /welcome');
                Navigator.pushNamed(context, '/welcome');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('TEST: Go to Welcome Page directly'),
            ),
          ),
        ],
      ),
    );
  }
}

// PRZYKŁADOWE STRONY
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: "Settings",
        showBackButton: true,
      ),
      body: Center(
        child: Text(
          "Settings Page",
          style: TextStyle(color: const Color(0xFF860E66)),
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: "Profile",
        showBackButton: true,
      ),
      body: Center(
        child: Text(
          "Profile Page",
          style: TextStyle(color: const Color(0xFF860E66)),
        ),
      ),
    );
  }
}

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: "Help",
        showBackButton: true,
      ),
      body: Center(
        child: Text(
          "Help Page",
          style: TextStyle(color: const Color(0xFF860E66)),
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: "About",
        showBackButton: true,
      ),
      body: Center(
        child: Text(
          "About Page",
          style: TextStyle(color: const Color(0xFF860E66)),
        ),
      ),
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
      final menuProvider = Provider.of<MenuProvider>(context, listen: false);
      menuProvider.setCurrentPage('ab_cd');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: "AB CD Page",
        showBackButton: true,
      ),
      body: Center(
        child: Text(
          "Strona AB CD",
          style: TextStyle(color: const Color(0xFF860E66)),
        ),
      ),
    );
  }
}

class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text("Login"),
              ),
            ),
            Center(
              child: Text(
                "Welcome!",
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF860E66),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
                child: const Text(
                  "Let's Start",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}