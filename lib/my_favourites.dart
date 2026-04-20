import 'package:flutter/material.dart';

class MyFavouritesPage extends StatelessWidget {
  const MyFavouritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favourites'),
      ),
      body: const Center(
        child: Text(
          'Your favourite items will appear here.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
