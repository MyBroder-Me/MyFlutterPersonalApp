import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/auth/auth_service.dart';
import 'package:myapp/auth/pages/sing_up_page.dart';

/// A stateful widget that represents the login page of the application.
class LoginPage extends StatefulWidget {
  /// Creates a [LoginPage] widget.
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// The state for the `LoginPage` widget.
class _LoginPageState extends State<LoginPage> {
  // Instance of the authentication service to handle login.
  final authService = AuthService();

  // Controllers to handle the input from the email and password text fields.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// Method to handle the login process.
  ///
  /// This method retrieves the email and password from the respective
  /// text controllers and attempts to sign in using the `AuthService`.
  /// If an error occurs during the sign-in process, an error dialog is shown.
  void login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      // Attempt to sign in with the provided email and password.
      await authService.signInWithEmailPassword(email, password);
    } catch (error) {
      if (mounted) {
        // Show an error dialog if the login fails.
        showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: const Text('Error'),
              content: Text("Wrong credentials."),
              actions: [
                CupertinoDialogAction(
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
            // Text field for email input.
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            // Text field for password input.
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            // Button to trigger the login process.
            CupertinoButton(
              onPressed: login,
              child: const Text('Login'),
            ),
            GestureDetector(
              child: Text('Don\'t have an account? Sing up'),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const SignUpPage())),
            )
          ],
        ),
      ),
    );
  }
}
