import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'main.dart' show routeObserver;
import 'widgets/main_app_bar.dart';
import 'providers/menu_provider.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> with RouteAware {
  bool _cancelled = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false).setCurrentPage('Help');
      routeObserver.subscribe(this, ModalRoute.of(context)!);
    });

    if (kIsWeb) {
      _injectKartraIfNeeded();
      _showKartra();
    }
  }

  @override
  void dispose() {
    _cancelled = true;
    routeObserver.unsubscribe(this);
    if (kIsWeb) _hideKartra();
    super.dispose();
  }

  @override
  void didPushNext() {
    _cancelled = true;
    if (kIsWeb) _hideKartra();
  }

  @override
  void didPopNext() {
    _cancelled = false;
    if (kIsWeb) _showKartra();
  }

  void _injectKartraIfNeeded() {
    if (html.document.getElementById('kartra_live_chat') != null) return;

    // CSS do <head>
    if (html.document.head!.querySelector('#kartra-css') == null) {
      final link = html.LinkElement()
        ..id = 'kartra-css'
        ..rel = 'stylesheet'
        ..type = 'text/css'
        ..href = 'https://app.kartra.com/css/new/css/kartra_helpdesk_sidebar_out.css';
      html.document.head!.append(link);
    }

    // Nadpisanie CSS – wyśrodkowanie formularza, przycisk poza ekranem
    if (html.document.head!.querySelector('#kartra-override-css') == null) {
      final style = html.StyleElement()..id = 'kartra-override-css';
      style.text = '''
        #display_kartra_helpdesk {
          position: fixed !important;
          left: -9999px !important;
          top: -9999px !important;
          visibility: hidden !important;
        }
        .kartra_helpdesk_sidebar_wrapper {
          position: fixed !important;
          top: 50% !important;
          left: 50% !important;
          transform: translate(-50%, -50%) !important;
          right: auto !important;
          bottom: auto !important;
          max-width: 520px !important;
          width: 90vw !important;
          max-height: 80vh !important;
          box-shadow: 0 8px 32px rgba(0,0,0,0.18) !important;
          border-radius: 16px !important;
          overflow: hidden !important;
          z-index: 9999 !important;
        }
      ''';
      html.document.head!.append(style);
    }

    // Kontener + skrypt + przycisk
    final container = html.DivElement()
      ..setAttribute('rel', 'JI7Z4DfvsCZa')
      ..setAttribute('article', '')
      ..setAttribute('product', '')
      ..setAttribute('embedded', '1')
      ..id = 'kartra_live_chat'
      ..className = 'kartra_helpdesk_sidebar js_kartra_trackable_object'
      ..style.display = 'none';

    final script = html.ScriptElement()
      ..type = 'text/javascript'
      ..src = 'https://app.kartra.com/resources/js/helpdesk_frame';
    container.append(script);

    final button = html.DivElement()
      ..setAttribute('rel', 'JI7Z4DfvsCZa')
      ..id = 'display_kartra_helpdesk'
      ..className = 'kartra_helpdesk_sidebar_button open';
    container.append(button);

    html.document.body!.append(container);
  }

  void _showKartra() {
    _cancelled = false;
    html.document.getElementById('kartra_live_chat')?.style.display = '';
    html.document.querySelectorAll('.kartra_helpdesk_sidebar_wrapper')
        .forEach((el) => (el as html.HtmlElement).style.display = '');

    _autoOpenKartra(attempt: 0);
  }

  void _autoOpenKartra({required int attempt}) {
    if (_cancelled) return;
    if (attempt > 40) return;
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_cancelled || !mounted) return;

      final btn = html.document.getElementById('display_kartra_helpdesk');
      if (btn == null) {
        // Skrypt Kartra jeszcze się ładuje – czekaj dalej
        _autoOpenKartra(attempt: attempt + 1);
        return;
      }

      // Przycisk istnieje – kliknij DOKŁADNIE RAZ i zakończ
      _cancelled = true;
      btn.dispatchEvent(html.Event('click', canBubble: true, cancelable: true));
    });
  }

  void _hideKartra() {
    html.document.getElementById('kartra_live_chat')?.style.display = 'none';
    // Ukryj wszystkie elementy które Kartra mogła wstrzyknąć dynamicznie
    for (final selector in [
      '.kartra_helpdesk_sidebar_wrapper',
      '.kartra_helpdesk_sidebar_overlay',
      '.kartra_helpdesk_overlay',
      '.js_kartra_helpdesk_wrapper',
    ]) {
      html.document.querySelectorAll(selector)
          .forEach((el) => (el as html.HtmlElement).style.display = 'none');
    }
    // Usuń blur z body jeśli Kartra go dodała
    html.document.body?.style.removeProperty('filter');
    html.document.body?.style.removeProperty('overflow');
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
                'Helpdesk form will appear shortly...',
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