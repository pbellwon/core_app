import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'main.dart' show routeObserver;
import 'widgets/main_app_bar.dart';
import 'providers/menu_provider.dart';

class RequestResourcePage extends StatefulWidget {
  const RequestResourcePage({super.key});

  @override
  State<RequestResourcePage> createState() => _RequestResourcePageState();
}

class _RequestResourcePageState extends State<RequestResourcePage> with RouteAware {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false).setCurrentPage('Request Resource');
      routeObserver.subscribe(this, ModalRoute.of(context)!);
    });

    if (kIsWeb) {
      _injectKartraIfNeeded();
      _showKartra();
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    if (kIsWeb) _hideKartra();
    super.dispose();
  }

  @override
  void didPushNext() {
    if (kIsWeb) _hideKartra();
  }

  @override
  void didPopNext() {
    if (kIsWeb) _showKartra();
  }

  void _injectKartraIfNeeded() {
    if (html.document.getElementById('kartra_survey_wrapper') != null) return;

    // Wrapper – nasze własne scrollowane okno nad Flutterowym canvas
    final wrapper = html.DivElement()
      ..id = 'kartra_survey_wrapper'
      ..style.cssText = 'position:fixed;top:56px;left:0;right:0;bottom:0;'
          'overflow-y:auto;z-index:9999;background:white;display:none;';

    // Kontener Kartra wewnątrz wrappera
    final container = html.DivElement()
      ..id = 'kartra_survey'
      ..className = 'js_kt_asset_embed js_kartra_trackable_object'
      ..setAttribute('data-kt-type', 'survey')
      ..setAttribute('data-kt-embed', 'inline')
      ..setAttribute('data-kt-value', 'Eceg6JSk9XCp')
      ..setAttribute('data-kt-owner', 'Nr5PyaWk')
      ..setAttribute('data-kt-accent', '#b31288');

    wrapper.append(container);
    html.document.body!.append(wrapper);

    // Skrypt Kartra
    final script = html.ScriptElement()
      ..type = 'text/javascript'
      ..src = 'https://app.kartra.com/js/build/front/embed/survey.js';
    html.document.body!.append(script);

    // Przechwytuj wheel events zanim Flutter je zablokuje (capture phase)
    final scrollFix = html.ScriptElement()
      ..text = '''
        document.getElementById('kartra_survey_wrapper')
          .addEventListener('wheel', function(e) {
            e.stopImmediatePropagation();
          }, true);
      ''';
    html.document.body!.append(scrollFix);
  }

  void _showKartra() {
    html.document.getElementById('kartra_survey_wrapper')?.style.display = '';
  }

  void _hideKartra() {
    html.document.getElementById('kartra_survey_wrapper')?.style.display = 'none';
    html.document.body?.style.removeProperty('overflow');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: "", showBackButton: false),
      body: const SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.note_add_outlined, size: 64, color: Color(0xFF860E66)),
              SizedBox(height: 24),
              Text(
                'Request a Resource',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'Survey form will appear shortly...',
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

