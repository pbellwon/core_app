import 'package:flutter/material.dart';
import 'widgets/main_app_bar.dart';
import 'widgets/menu_overlay.dart';

class MyFavouritesPage extends StatelessWidget {
  const MyFavouritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MenuOverlay(
      child: Scaffold(
        appBar: const MainAppBar(
          title: '',
          showBackButton: true,
        ),
        body: const Center(
          child: Text(
            'Your favourite items will appear here.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
