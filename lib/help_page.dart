import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

import 'widgets/main_app_bar.dart';
import 'providers/menu_provider.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false)
          .setCurrentPage('Help');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Rejestracja iframe tylko na web
      // ignore: undefined_prefixed_name
      // ignore: avoid_web_libraries_in_flutter
      final String viewID = 'kartra-helpdesk-iframe';
      // ignore: undefined_prefixed_name
      html.Element? existing = html.document.getElementById(viewID);
      if (existing == null) {
        final iframe = html.IFrameElement()
          ..id = viewID
          ..srcdoc = '''
            <html>
              <head>
                <link rel="stylesheet" type="text/css" href="https://app.kartra.com/css/new/css/kartra_helpdesk_sidebar_out.css" />
              </head>
              <body>
                <div rel="JI7Z4DfvsCZa" article="" product="" embedded="1" id="kartra_live_chat" class="kartra_helpdesk_sidebar js_kartra_trackable_object">
                  <script type="text/javascript" src="https://app.kartra.com/resources/js/helpdesk_frame"></script>
                  <div rel="JI7Z4DfvsCZa" id="display_kartra_helpdesk" class="kartra_helpdesk_sidebar_button open"></div>
                </div>
              </body>
            </html>
          '''
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100vh';
        html.document.body!.append(iframe);
      }
      return Scaffold(
        appBar: const MainAppBar(title: "", showBackButton: true),
        body: const SafeArea(
          child: HtmlElementView(viewType: 'kartra-helpdesk-iframe'),
        ),
      );
    } else {
      return Scaffold(
        appBar: const MainAppBar(title: "", showBackButton: true),
        body: const Center(
          child: Text('Live chat dostępny tylko w wersji web.'),
        ),
      );
    }
  }
}