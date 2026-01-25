import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';

class SupabaseConfig {
  final String url;
  final String anonKey;

  const SupabaseConfig({
    required this.url,
    required this.anonKey,
  });

  factory SupabaseConfig.fromJson(Map<String, dynamic> json) {
    return SupabaseConfig(
      url: json['url'] as String,
      anonKey: json['anon_key'] as String,
    );
  }
}

class StorageConfig {
  final String url;
  final String accessKey;
  final String secretKey;
  final String region;

  const StorageConfig({
    required this.url,
    required this.accessKey,
    required this.secretKey,
    required this.region,
  });

  factory StorageConfig.fromJson(Map<String, dynamic> json) {
    return StorageConfig(
      url: json['url'] as String,
      accessKey: json['access_key'] as String,
      secretKey: json['secret_key'] as String,
      region: json['region'] as String,
    );
  }
}

class AppConfig {
  final String env;
  final bool enableLogging;
  final SupabaseConfig supabase;
  final StorageConfig storage;

  const AppConfig({
    required this.env,
    required this.enableLogging,
    required this.supabase,
    required this.storage,
  });

  /// Global instance - set during app initialization
  static late AppConfig instance;

  /// Get environment from --dart-define=ENV=dev (defaults to 'dev')
  static const String environment =
      String.fromEnvironment('ENV', defaultValue: 'dev');

  /// Whether we're in development mode
  bool get isDevelopment => env == 'development';

  /// Whether we're in production mode
  bool get isProduction => env == 'production';

  /// Get platform-specific URL from config.
  /// Uses url_android if on Android and available, otherwise falls back to url.
  static String _getUrl(Map<String, dynamic> json) {
    final androidUrl = json['url_android'] as String?;
    final defaultUrl = json['url'] as String;
    return (Platform.isAndroid && androidUrl != null) ? androidUrl : defaultUrl;
  }

  /// Load configuration from JSON asset file based on ENV
  static Future<AppConfig> load() async {
    final jsonString = await rootBundle.loadString(
      'assets/config/$environment.json',
    );
    final json = jsonDecode(jsonString) as Map<String, dynamic>;

    final supabaseJson = json['supabase'] as Map<String, dynamic>;
    final storageJson = json['storage'] as Map<String, dynamic>;

    final config = AppConfig(
      env: json['env'] as String,
      enableLogging: json['enable_logging'] as bool? ?? false,
      supabase: SupabaseConfig(
        url: _getUrl(supabaseJson),
        anonKey: supabaseJson['anon_key'] as String,
      ),
      storage: StorageConfig(
        url: _getUrl(storageJson),
        accessKey: storageJson['access_key'] as String,
        secretKey: storageJson['secret_key'] as String,
        region: storageJson['region'] as String,
      ),
    );

    instance = config;
    return config;
  }

  /// Log only in development
  void log(String message) {
    if (enableLogging) {
      print('[$env] $message');
    }
  }
}
