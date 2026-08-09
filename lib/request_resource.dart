import 'package:flutter/material.dart';
import 'widgets/main_app_bar.dart';

class RequestResourcePage extends StatelessWidget {
  const RequestResourcePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MainAppBar(
        title: 'Request Resource',
        showBackButton: false,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.card_giftcard,
                size: 80,
                color: Color(0xFF860E66),
              ),
              SizedBox(height: 24),
              Text(
                'Request Resource',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF860E66),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'What resources would you like to access?',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF860E66),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
