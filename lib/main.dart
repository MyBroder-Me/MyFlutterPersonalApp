import 'package:flutter/material.dart';
import 'package:myapp/config/app_config.dart';
import 'package:myapp/controller/auth_service.dart';
import 'package:myapp/controller/pages/login_page.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'controller/book_service.dart';
import 'model/main_state.dart';
import 'view/menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load configuration from JSON (ENV comes from --dart-define)
  final config = await AppConfig.load();
  config.log('Starting app with ${config.env} configuration');
  config.log('Supabase URL: ${config.supabase.url}');

  // Initialize Supabase with config values
  await Supabase.initialize(
    url: config.supabase.url,
    anonKey: config.supabase.anonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _isLoggedIn() async {
    final session = Supabase.instance.client.auth.currentSession;
    return session != null;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MyAppState()),
        Provider<BookService>(
            create: (_) => BookService(Supabase.instance.client)),
        Provider<AuthService>(
          create: (_) => AuthService(),
        )
      ],
      child: MaterialApp(
        title: 'My App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: FutureBuilder<bool>(
          future: _isLoggedIn(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasData && snapshot.data == true) {
              return Menu();
            } else {
              return LoginPage();
            }
          },
        ),
      ),
    );
  }
}
