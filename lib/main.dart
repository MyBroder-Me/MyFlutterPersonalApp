import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/controller/pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'model/main_state.dart';
import 'view/menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://jgywuqgtfzblbaqprvdb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpneXd1cWd0ZnpibGJhcXBydmRiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYwMTg3NjQsImV4cCI6MjA1MTU5NDc2NH0.A2lzmtfewM5Rm9LpZlWq4u9fjcPHwmjYNk-y5wD_dBo',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _isLoggedIn() async {
    final session = Supabase.instance.client.auth.currentSession;
    return session != null;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
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
              return const CircularProgressIndicator();
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
