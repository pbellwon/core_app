import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import 'main.dart' show routeObserver;
import 'kartra_survey_embed.dart';
import 'widgets/main_app_bar.dart';
import 'providers/menu_provider.dart';

class RequestResourcePage extends StatefulWidget {
  const RequestResourcePage({super.key});

  @override
  State<RequestResourcePage> createState() => _RequestResourcePageState();
}

class _RequestResourcePageState extends State<RequestResourcePage>
    with RouteAware {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(
        context,
        listen: false,
      ).setCurrentPage('Request Resource');
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
    mountKartraSurvey(
      wrapperId: 'kartra_survey_wrapper',
      surveyId: 'Eceg6JSk9XCp',
      owner: 'Nr5PyaWk',
      accent: '#b31288',
    );
  }

  void _showKartra() => showKartraSurvey('kartra_survey_wrapper');

  void _hideKartra() => hideKartraSurvey('kartra_survey_wrapper');

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
