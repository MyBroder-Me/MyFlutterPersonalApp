// lib/auth/pages/profile_page.dart
import 'package:flutter/material.dart';

import '../../ui/auth/profile_scaffold.dart';
import '../auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final authService = AuthService();

  void logout() async {
    await authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final email = authService.getCurrentUserEmail();
    return ProfileScaffold(
      email: email,
      onLogout: logout,
    );
  }
}
