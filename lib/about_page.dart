import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/main_app_bar.dart';
import 'providers/menu_provider.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false)
          .setCurrentPage('about');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: "", showBackButton: true),
      body: const Center(
        child: Text(
          'About Page\nThis is the about page.',
          style: TextStyle(fontSize: 24, color: Color(0xFF860E66)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}