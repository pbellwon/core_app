import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/main_app_bar.dart';
import 'providers/menu_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false)
          .setCurrentPage('Settings');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: "", showBackButton: true),
      body: const Center(
        child: Text(
          'Settings Page\nThis is the Settings page.',
          style: TextStyle(fontSize: 24, color: Color(0xFF860E66)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}