import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'widgets/main_app_bar.dart';
import 'providers/menu_provider.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  static bool _kartraInjected = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false).setCurrentPage('Help');
    });

    if (kIsWeb && !_kartraInjected) {
      _kartraInjected = true;
      _injectKartra();
    }
  }

  void _injectKartra() {
    // 1. CSS do <head>
    if (html.document.head!.querySelector('#kartra-css') == null) {
      final link = html.LinkElement()
        ..id = 'kartra-css'
        ..rel = 'stylesheet'
        ..type = 'text/css'
        ..href = 'https://app.kartra.com/css/new/css/kartra_helpdesk_sidebar_out.css';
      html.document.head!.append(link);
    }

    // 2. Kontener + skrypt + przycisk – dokładnie jak w oryginalnym kodzie Kartra
    if (html.document.getElementById('kartra_live_chat') == null) {
      final container = html.DivElement()
        ..setAttribute('rel', 'JI7Z4DfvsCZa')
        ..setAttribute('article', '')
        ..setAttribute('product', '')
        ..setAttribute('embedded', '1')
        ..id = 'kartra_live_chat'
        ..className = 'kartra_helpdesk_sidebar js_kartra_trackable_object';

      // Skrypt WEWNĄTRZ kontenera (wymagane przez Kartra)
      final script = html.ScriptElement()
        ..type = 'text/javascript'
        ..src = 'https://app.kartra.com/resources/js/helpdesk_frame';
      container.append(script);

      // Przycisk helpdesku
      final button = html.DivElement()
        ..setAttribute('rel', 'JI7Z4DfvsCZa')
        ..id = 'display_kartra_helpdesk'
        ..className = 'kartra_helpdesk_sidebar_button open';
      container.append(button);

      html.document.body!.append(container);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: "", showBackButton: true),
      body: const SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.headset_mic_outlined, size: 64, color: Color(0xFF860E66)),
              SizedBox(height: 24),
              Text(
                'Need help?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'Click the helpdesk button on the right side,\nto contact support.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}