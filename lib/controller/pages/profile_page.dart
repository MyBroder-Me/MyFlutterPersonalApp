// lib/auth/pages/profile_page.dart
import 'package:flutter/cupertino.dart';
import 'package:myapp/controller/navigation.dart';
import 'package:provider/provider.dart';

import '../../view/auth/profile_scaffold.dart';
import '../auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final NavigationService _navigationService = NavigationService();

  void logout() async {
    await Provider.of<AuthService>(context, listen: false).signOut();
    if (mounted) _navigationService.navigateToLogin(context);
  }

  void deleteAccount() async {
    await Provider.of<AuthService>(context, listen: false).deleteAccount();
    if (mounted) _navigationService.navigateToLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    final email =
        Provider.of<AuthService>(context, listen: false).getCurrentUserEmail();
    return ProfileScaffold(
      email: email,
      onLogout: logout,
      onDeleteAccount: deleteAccount,
    );
  }
}
