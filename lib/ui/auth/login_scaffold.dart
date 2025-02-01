// lib/components/login_scaffold.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginScaffold extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;
  final VoidCallback onSignUp;

  const LoginScaffold({
    Key? key,
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
    required this.onSignUp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            CupertinoButton(
              onPressed: onLogin,
              child: const Text('Login'),
            ),
            GestureDetector(
              child: const Text('Don\'t have an account? Sign up'),
              onTap: onSignUp,
            ),
          ],
        ),
      ),
    );
  }
}
