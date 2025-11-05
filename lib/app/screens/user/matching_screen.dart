import 'package:flutter/material.dart';

class UserMatchingScreen extends StatelessWidget {
  const UserMatchingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matching'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('Matching Screen - Coming Soon'),
      ),
    );
  }
}