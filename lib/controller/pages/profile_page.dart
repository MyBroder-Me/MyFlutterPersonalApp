// lib/auth/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:myapp/controller/navigation.dart';

import '../../view/auth/profile_scaffold.dart';
import '../auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final authService = AuthService();
  final NavigationService _navigationService = NavigationService();

  void logout() async {
    await authService.signOut();
    if (mounted) _navigationService.navigateToLogin(context);
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
