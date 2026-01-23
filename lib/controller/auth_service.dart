import 'package:supabase_flutter/supabase_flutter.dart';

/// A service class to manage authentication using Supabase.
/// This class provides methods for signing in, signing up, signing out,
/// and retrieving the currently authenticated user's email.
class AuthService {
  /// Instance of Supabase client for authentication operations.
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Signs in a user with email and password.
  ///
  /// Parameters:
  /// - [email]: The user's email address.
  /// - [password]: The user's password.
  ///
  /// Returns:
  /// - A [Future] that resolves to an [AuthResponse] containing authentication details.
  Future<AuthResponse> signInWithEmailPassword(
      String email, String password) async {
    return await _supabase.auth
        .signInWithPassword(email: email, password: password);
  }

  /// Registers a new user with email and password.
  ///
  /// Parameters:
  /// - [email]: The email address to register.
  /// - [password]: The password for the new account.
  ///
  /// Returns:
  /// - A [Future] that resolves to an [AuthResponse] containing the new user's details.
  Future<AuthResponse> signUpWithEmailPassword(
      String email, String password) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  /// Signs out the currently authenticated user.
  ///
  /// Returns:
  /// - A [Future] that completes when the user is signed out.
  Future<void> signOut() async {
    return await _supabase.auth.signOut();
  }

  /// Retrieves the email of the currently authenticated user.
  ///
  /// Returns:
  /// - The email of the authenticated user, or `null` if no user is logged in.
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

  /// Disables account by setting disabled_at timestamp.
  /// This preserves all user data including purchases.
  Future<void> disableAccount() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      await _supabase.from('profiles').update({
        'disabled_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', user.id);
      await _supabase.auth.signOut();
    }
  }

  /// Checks if the current user's account is disabled.
  /// Returns the disabled_at timestamp if disabled, null if active.
  Future<DateTime?> checkAccountDisabled() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final response = await _supabase
        .from('profiles')
        .select('disabled_at')
        .eq('id', user.id)
        .single();

    final disabledAt = response['disabled_at'];
    return disabledAt != null ? DateTime.parse(disabledAt) : null;
  }

  /// Re-enables account by clearing disabled_at.
  Future<void> enableAccount() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      await _supabase.from('profiles').update({
        'disabled_at': null,
      }).eq('id', user.id);
    }
  }
}
