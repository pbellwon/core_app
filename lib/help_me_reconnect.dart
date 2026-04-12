import 'package:flutter/material.dart';
import 'widgets/main_app_bar.dart';

class HelpMeReconnectPage extends StatelessWidget {
  const HelpMeReconnectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MainAppBar(
        title: '',
        showBackButton: false,
      ),
      body: Center(
        child: Text('Help Me Reconnect Page'),
      ),
    );
  }
}
