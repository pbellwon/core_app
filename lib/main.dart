import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'get_started.dart';



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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFF7E7F3),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFF7E7F3),
          foregroundColor: Color(0xFF860E66),
        ),
        textTheme: TextTheme(
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
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.hovered)) {
                  return Color(0xFFFF854D);
                }
                return Color(0xFFB31288);
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
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFB31288),
          foregroundColor: Colors.white,
          hoverColor: Color(0xFFFF854D),
        ),
      ),
      home: LoginPage(),
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
            // GÓRNY PRZYCISK (LOGIN)
            Positioned(
              top: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                  );
                },
                child: Text("Login"),
              ),
            ),

            // ZAWARTOŚĆ STRONY (TITLE)
            Center(
              child: Text(
                "Welcome!",
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // COFKA DOLNY PRZYCISK "LET'S START"
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GetStarted()),
                  );
                },
                child: Text(
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
