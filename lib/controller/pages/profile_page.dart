import 'package:flutter/material.dart';
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

  void disableAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable Account'),
        content: const Text(
          'Your account will be disabled and you will be signed out. '
          'You can re-enable it by logging in again. '
          'Your data and purchases will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Disable'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await Provider.of<AuthService>(context, listen: false).disableAccount();
      if (mounted) _navigationService.navigateToLogin(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email =
        Provider.of<AuthService>(context, listen: false).getCurrentUserEmail();
    return ProfileScaffold(
      email: email,
      onLogout: logout,
      onDisableAccount: disableAccount,
    );
  }
}
