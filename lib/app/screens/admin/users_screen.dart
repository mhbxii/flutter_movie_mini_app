import 'package:flutter/material.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('Users Management Screen - Coming Soon'),
      ),
    );
  }
}