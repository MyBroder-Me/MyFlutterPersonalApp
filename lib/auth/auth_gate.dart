import 'package:flutter/material.dart';
import 'package:myapp/auth/pages/login_page.dart';
import 'package:myapp/auth/pages/profile_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A widget that manages the authentication state of the application.
/// It listens to the authentication state changes and displays the appropriate
/// page based on whether the user is authenticated or not.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // Listens to the authentication state changes.
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // While waiting for the authentication state, show a loading indicator.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Get the current session if available.
        final session = snapshot.hasData ? snapshot.data!.session : null;

        // If the user is authenticated, show the ProfilePage.
        // Otherwise, show the LoginPage.
        if (session != null) {
          return ProfilePage();
          //return ProfilePage();
        } else {
          return LoginPage();
        }
      },
    );
  }
}
