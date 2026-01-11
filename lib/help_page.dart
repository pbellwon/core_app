import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    return Scaffold(
      appBar: const MainAppBar(title: "", showBackButton: true),
      body: const Center(
        child: Text(
          'Help Page\nThis is the Help page.',
          style: TextStyle(fontSize: 24, color: Color(0xFF860E66)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}