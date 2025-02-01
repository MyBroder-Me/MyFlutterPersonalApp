import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
            },
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
              onPressed: () async {
                // Sign out the user.
                await authService.signOut();
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
