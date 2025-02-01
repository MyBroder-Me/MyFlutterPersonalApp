// lib/components/profile_scaffold.dart
import 'package:flutter/material.dart';

class ProfileScaffold extends StatelessWidget {
  final String? email;
  final VoidCallback onLogout;

  const ProfileScaffold({
    super.key,
    required this.email,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: onLogout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, $email'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onLogout,
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
