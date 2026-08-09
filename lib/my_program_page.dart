import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/main_app_bar.dart';
import 'providers/menu_provider.dart';

class MyProgramPage extends StatefulWidget {
  const MyProgramPage({super.key});

  @override
  State<MyProgramPage> createState() => _MyProgramPageState();
}

class _MyProgramPageState extends State<MyProgramPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false)
          .setCurrentPage('MyProgram');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: '', showBackButton: true),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.check_box_outlined,
              size: 80,
              color: Color(0xFF860E66),
            ),
            SizedBox(height: 24),
            Text(
              'My Program',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF860E66),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Your personalized program',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF860E66),
              ),
            ),
            SizedBox(height: 32),
            Text(
              'This is your dedicated space to track and manage your personalized program. Here you can view your progress, explore recommended activities, and stay connected with your wellness journey.',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
