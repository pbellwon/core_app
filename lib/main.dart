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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        home: const RootPage(),
      ),
    );
  }
}

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppAuthProvider>(
      builder: (context, authProvider, child) {
        // POKAŻ ŁADOWANIE
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

        // SPRAWDŹ CZY ZALOGOWANY
        if (authProvider.isLoggedIn) {
          // JEST ZALOGOWANY - IDŹ DO GET_STARTED Z MainAppBar
          return const GetStartedPageWithAppBar();
        } else {
          // NIE ZALOGOWANY - IDŹ DO LOGIN_PAGE BEZ MainAppBar
          return const LoginPage();
        }
      },
    );
  }
}

// GET_STARTED Z MainAppBar
class GetStartedPageWithAppBar extends StatefulWidget {
  const GetStartedPageWithAppBar({super.key});

  @override
  State<GetStartedPageWithAppBar> createState() => _GetStartedPageWithAppBarState();
}

class _GetStartedPageWithAppBarState extends State<GetStartedPageWithAppBar> {
  @override
  void initState() {
    super.initState();
    // Ustaw stronę dla menu PO zbudowaniu widgetu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final menuProvider = Provider.of<MenuProvider>(context, listen: false);
      menuProvider.setCurrentPage('get_started');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: "Get Started",
        showBackButton: false,
      ),
      body: GetStarted(),
    );
  }
}

// PRZYKŁAD: Jak używać na innych stronach
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

class WelcomePageWithAppBar extends StatefulWidget {
  const WelcomePageWithAppBar({super.key});

  @override
  State<WelcomePageWithAppBar> createState() => _WelcomePageWithAppBarState();
}

class _WelcomePageWithAppBarState extends State<WelcomePageWithAppBar> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final menuProvider = Provider.of<MenuProvider>(context, listen: false);
      menuProvider.setCurrentPage('welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: "Welcome",
        showBackButton: true,
      ),
      body: Center(
        child: Text(
          "Strona Welcome",
          style: TextStyle(color: const Color(0xFF860E66)),
        ),
      ),
    );
  }
}

// Zachowujemy oryginalną TitlePage jeśli jest używana gdzieś indziej
class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // GÓRNY PRZYCISK (LOGIN)
            Positioned(
              top: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: const Text("Login"),
              ),
            ),

            // ZAWARTOŚĆ STRONY (TITLE)
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

            // DOLNY PRZYCISK "LET'S START"
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GetStartedPageWithAppBar()),
                  );
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