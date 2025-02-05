// lib/view/auth/profile_scaffold.dart
import 'package:flutter/material.dart';

class ProfileScaffold extends StatelessWidget {
  final String? email;
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;

  const ProfileScaffold({
    super.key,
    required this.email,
    required this.onLogout,
    required this.onDeleteAccount,
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
            onPressed: onDeleteAccount,
            child: const Text('Delete Account'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Red color for delete button
            ),
          ),
        ],
      ),
    );
  }
}
