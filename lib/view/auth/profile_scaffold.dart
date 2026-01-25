// lib/view/auth/profile_scaffold.dart
import 'package:flutter/material.dart';

class ProfileScaffold extends StatelessWidget {
  final String? email;
  final VoidCallback onLogout;
  final VoidCallback onDisableAccount;

  const ProfileScaffold({
    super.key,
    required this.email,
    required this.onLogout,
    required this.onDisableAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Welcome, $email'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onLogout,
            child: const Text('Sign Out'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onDisableAccount,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Disable Account'),
          ),
        ],
      ),
    );
  }
}
