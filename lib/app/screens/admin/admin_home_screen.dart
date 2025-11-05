import 'package:flutter/material.dart';
import '../../widgets/admin_bottom_nav.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminBottomNav(initialIndex: 0);
  }
}