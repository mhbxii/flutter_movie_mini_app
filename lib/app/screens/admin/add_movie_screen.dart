import 'package:flutter/material.dart';

class AdminAddMovieScreen extends StatelessWidget {
  const AdminAddMovieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Movie'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('Add Movie Screen - Coming Soon'),
      ),
    );
  }
}