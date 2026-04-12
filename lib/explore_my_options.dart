// lib/explore_my_options.dart

import 'package:flutter/material.dart';
import 'widgets/main_app_bar.dart';

class ExploreMyOptionsPage extends StatelessWidget {
  const ExploreMyOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MainAppBar(
        title: '',
        showBackButton: true,
      ),
      body: Center(
        child: Text('Explore My Options Page'),
      ),
    );
  }
}