import 'package:flutter/material.dart';
import '../../widgets/user_bottom_nav.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const UserBottomNav(initialIndex: 0);
  }
}