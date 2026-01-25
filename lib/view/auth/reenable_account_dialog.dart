import 'package:flutter/material.dart';

/// Shows a dialog asking if the user wants to re-enable their disabled account.
/// Returns true if user wants to re-enable, false if they want to stay signed out.
Future<bool> showReenableAccountDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('Account Disabled'),
      content: const Text(
        'Your account is currently disabled. Would you like to re-enable it?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('No, Sign Out'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Yes, Re-enable'),
        ),
      ],
    ),
  );
  return result ?? false;
}
