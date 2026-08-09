import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/main_app_bar.dart';
import 'providers/menu_provider.dart';

class ShareFeedbackPage extends StatefulWidget {
  const ShareFeedbackPage({super.key});

  @override
  State<ShareFeedbackPage> createState() => _ShareFeedbackPageState();
}

class _ShareFeedbackPageState extends State<ShareFeedbackPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false)
          .setCurrentPage('ShareFeedback');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: "", showBackButton: true),
      body: const Center(
        child: Text(
          'Share Your Feedback Page\nThis is the Share Your Feedback page.',
          style: TextStyle(fontSize: 24, color: Color(0xFF860E66)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
