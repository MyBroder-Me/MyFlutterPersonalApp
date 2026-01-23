#!/usr/bin/env dart
// Generates .vscode/launch.json with correct device IDs for this machine
// Run: dart scripts/setup_launch.dart

import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔍 Finding devices...\n');

  // Get devices as JSON
  final result = await Process.run('flutter', ['devices', '--machine']);
  if (result.exitCode != 0) {
    print('❌ Failed to get devices: ${result.stderr}');
    exit(1);
  }

  final devices = jsonDecode(result.stdout as String) as List;

  // Find iOS and Android devices
  String? iosId;
  String? androidId;
  String? iosName;
  String? androidName;

  for (final device in devices) {
    final platform = device['targetPlatform'] as String;
    final id = device['id'] as String;
    final name = device['name'] as String;

    if (platform == 'ios' && iosId == null) {
      iosId = id;
      iosName = name;
    } else if (platform.startsWith('android') && androidId == null) {
      androidId = id;
      androidName = name;
    }
  }

  print('📱 iOS: ${iosName ?? "not found"} (${iosId ?? "N/A"})');
  print('🤖 Android: ${androidName ?? "not found"} (${androidId ?? "N/A"})\n');

  // Generate launch.json
  final launchJson = {
    'version': '0.2.0',
    'configurations': [
      {
        'name': 'Dev',
        'request': 'launch',
        'type': 'dart',
        'args': ['--dart-define=ENV=dev'],
      },
      {
        'name': 'Prod',
        'request': 'launch',
        'type': 'dart',
        'args': ['--dart-define=ENV=prod'],
      },
      if (iosId != null)
        {
          'name': 'Dev (iOS)',
          'request': 'launch',
          'type': 'dart',
          'deviceId': iosId,
          'args': ['--dart-define=ENV=dev'],
        },
      if (androidId != null)
        {
          'name': 'Dev (Android)',
          'request': 'launch',
          'type': 'dart',
          'deviceId': androidId,
          'args': ['--dart-define=ENV=dev'],
        },
      if (iosId != null)
        {
          'name': 'Prod (iOS)',
          'request': 'launch',
          'type': 'dart',
          'deviceId': iosId,
          'args': ['--dart-define=ENV=prod'],
        },
      if (androidId != null)
        {
          'name': 'Prod (Android)',
          'request': 'launch',
          'type': 'dart',
          'deviceId': androidId,
          'args': ['--dart-define=ENV=prod'],
        },
      {
        'name': 'Dev (Profile)',
        'request': 'launch',
        'type': 'dart',
        'flutterMode': 'profile',
        'args': ['--dart-define=ENV=dev'],
      },
      {
        'name': 'Prod (Release)',
        'request': 'launch',
        'type': 'dart',
        'flutterMode': 'release',
        'args': ['--dart-define=ENV=prod'],
      },
    ],
    'compounds': [
      if (iosId != null && androidId != null)
        {
          'name': 'Dev (iOS + Android)',
          'configurations': ['Dev (iOS)', 'Dev (Android)'],
        },
      if (iosId != null && androidId != null)
        {
          'name': 'Prod (iOS + Android)',
          'configurations': ['Prod (iOS)', 'Prod (Android)'],
        },
    ],
  };

  // Write to file
  final vscodeDir = Directory('.vscode');
  if (!vscodeDir.existsSync()) {
    vscodeDir.createSync();
  }

  final file = File('.vscode/launch.json');
  final encoder = JsonEncoder.withIndent('  ');
  file.writeAsStringSync(encoder.convert(launchJson));

  print('✅ Generated .vscode/launch.json');
  print('   Restart VS Code or reload window to apply changes.');
}
