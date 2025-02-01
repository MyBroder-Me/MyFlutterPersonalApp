// lib/auth/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:myapp/controller/navigation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../view/auth/login_scaffold.dart';
import '../auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final NavigationService _navigationService = NavigationService();

  void login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      await authService.signInWithEmailPassword(email, password);
      if (mounted) _navigationService.navigateToMain(context);
    } catch (error) {
      if (mounted) {
        if (error is AuthException &&
            error.message == 'Invalid login credentials') {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text('Invalid credentials.'),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              );
            },
          );
          return;
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text('Server error, try again later.'),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }

  void signUp() {
    _navigationService.navigateToSignUp(context);
  }

  @override
  Widget build(BuildContext context) {
    return LoginScaffold(
      emailController: _emailController,
      passwordController: _passwordController,
      onLogin: login,
      onSignUp: signUp,
    );
  }
}
