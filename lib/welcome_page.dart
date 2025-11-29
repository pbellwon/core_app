import 'package:flutter/material.dart';
import 'terms_and_conditions.dart';

class CoreContentPage extends StatelessWidget {
  const CoreContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welome to Core Content")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "What kind of expirience would be most helpful for You in this moment ?",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            // BUTTON 1
            ElevatedButton(
              onPressed: () {
                // TODO: przejście do odpowiedniej podstrony
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: Text("Help me reconnect"),
            ),

            SizedBox(height: 20),

            // BUTTON 2
            ElevatedButton(
              onPressed: () {
                // TODO: przejście do odpowiedniej podstrony
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: Text("Show me what's possible"),
            ),

            SizedBox(height: 20),

            // BUTTON 3
            ElevatedButton(
              onPressed: () {
                // TODO: przejście do odpowiedniej podstrony
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: Text("Go to my favourites"),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Terms & Conditions',
        mini: true,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TermsAndConditionsPage()),
          );
        },
        child: Icon(Icons.description),
      ),
    );
  }
}
