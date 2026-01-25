#!/usr/bin/env dart
// Unified launcher for Flutter development.
//
// Usage:
//   dart run scripts/start.dart android
//   dart run scripts/start.dart ios
//   dart run scripts/start.dart both
//
// This script:
// 1. Prompts for environment (dev/prod) and build mode (debug/profile/release)
// 2. Ensures required emulators are running
// 3. Generates VS Code launch.json with correct device IDs
// 4. Triggers VS Code debug session

import 'dart:convert';
import 'dart:io';

const Duration deviceTimeout = Duration(seconds: 120);
const Duration pollInterval = Duration(seconds: 2);

void main(List<String> args) async {
  final platform = _parsePlatform(args);

  if (platform == null) {
    _printUsage();
    exit(1);
  }

  print('');
  print('╔══════════════════════════════════════════════════════════════╗');
  print('║              Flutter Development Launcher                    ║');
  print('╚══════════════════════════════════════════════════════════════╝');
  print('');

  try {
    // Step 1: Prompt for configuration
    final env = await _promptChoice(
      'Select environment:',
      ['dev', 'prod'],
      defaultIndex: 0,
    );

    final mode = await _promptChoice(
      'Select build mode:',
      ['debug', 'profile', 'release'],
      defaultIndex: 0,
    );

    print('');
    print('Configuration: ENV=$env, mode=$mode');
    print('Platform: $platform');
    print('');

    // Step 2: Ensure devices are running
    String? androidId;
    String? iosId;

    if (platform == 'android' || platform == 'both') {
      print('Ensuring Android device...');
      androidId = await _ensureAndroidDevice();
      print('  Android ready: $androidId');
    }

    if (platform == 'ios' || platform == 'both') {
      if (!Platform.isMacOS) {
        print('Warning: iOS is only available on macOS');
        if (platform == 'ios') exit(1);
      } else {
        print('Ensuring iOS device...');
        iosId = await _ensureIOSDevice();
        print('  iOS ready: $iosId');
      }
    }

    // Step 3: Generate VS Code configuration
    print('');
    print('Generating VS Code configuration...');
    await _generateVSCodeConfig(
      env: env,
      mode: mode,
      platform: platform,
      androidId: androidId,
      iosId: iosId,
    );

    // Step 4: Launch VS Code debug session
    print('Launching VS Code debug session...');
    await _launchVSCodeDebug(platform);

    print('');
    print('Done! Check VS Code for the debug session.');
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

String? _parsePlatform(List<String> args) {
  if (args.isEmpty) return null;
  final platform = args[0].toLowerCase();
  if (!['android', 'ios', 'both'].contains(platform)) return null;
  return platform;
}

void _printUsage() {
  print('Usage: dart run scripts/start.dart <platform>');
  print('');
  print('Platforms:');
  print('  android  Launch on Android emulator');
  print('  ios      Launch on iOS simulator (macOS only)');
  print('  both     Launch on both platforms');
  print('');
  print('Or use derry:');
  print('  derry start:android');
  print('  derry start:ios');
  print('  derry start:both');
}

Future<String> _promptChoice(
  String prompt,
  List<String> options, {
  int defaultIndex = 0,
}) async {
  print(prompt);
  for (var i = 0; i < options.length; i++) {
    final marker = i == defaultIndex ? '*' : ' ';
    print('  $marker ${i + 1}. ${options[i]}');
  }
  stdout.write('Choice [${defaultIndex + 1}]: ');

  final input = stdin.readLineSync()?.trim() ?? '';
  if (input.isEmpty) return options[defaultIndex];

  final index = int.tryParse(input);
  if (index != null && index >= 1 && index <= options.length) {
    return options[index - 1];
  }

  // Try matching by name
  final match = options.firstWhere(
    (o) => o.toLowerCase() == input.toLowerCase(),
    orElse: () => options[defaultIndex],
  );
  return match;
}

// ============================================================================
// Device Management
// ============================================================================

Future<List<Map<String, dynamic>>> _getRunningDevices() async {
  final result = await Process.run('flutter', ['devices', '--machine'],
      runInShell: true);
  if (result.exitCode != 0) return [];

  final output = result.stdout as String;
  final jsonStart = output.indexOf('[');
  if (jsonStart == -1) return [];

  try {
    final devices = jsonDecode(output.substring(jsonStart)) as List;
    return devices.cast<Map<String, dynamic>>();
  } catch (_) {
    return [];
  }
}

Future<String> _ensureAndroidDevice() async {
  // Check if already running
  var devices = await _getRunningDevices();
  print('  Checking for running devices: ${devices.map((d) => d['id']).toList()}');
  for (final device in devices) {
    final platform = device['targetPlatform'] as String? ?? '';
    if (platform.startsWith('android')) {
      print('  Found running Android: ${device['id']}');
      return device['id'] as String;
    }
  }

  // Get available emulators using flutter
  final emulatorsResult = await Process.run(
    'flutter',
    ['emulators'],
    runInShell: true,
  );

  // Parse emulator IDs from output
  final lines = (emulatorsResult.stdout as String).split('\n');
  final emulatorIds = <String>[];
  for (final line in lines) {
    // Lines with emulator info contain "•" separators
    if (line.contains('•') && line.contains('android')) {
      final id = line.split('•').first.trim();
      if (id.isNotEmpty) emulatorIds.add(id);
    }
  }
  print('  Available emulators: $emulatorIds');

  // Create emulator if none exist
  String emulatorId;
  if (emulatorIds.isEmpty) {
    print('  Creating Android emulator...');
    await Process.run(
        'flutter', ['emulators', '--create', '--name', 'flutter_emulator'],
        runInShell: true);
    emulatorId = 'flutter_emulator';
  } else {
    emulatorId = emulatorIds.first;
  }

  // Launch emulator using flutter
  print('  Launching $emulatorId...');
  if (Platform.isWindows) {
    // On Windows, use START to launch truly independently
    await Process.run(
      'cmd',
      ['/c', 'start', '/b', 'flutter', 'emulators', '--launch', emulatorId],
    );
  } else {
    // On macOS/Linux, detached mode works properly
    await Process.start(
      'flutter',
      ['emulators', '--launch', emulatorId],
      mode: ProcessStartMode.detached,
      runInShell: true,
    );
  }

  // Wait for device to appear (using adb - faster, no CMD window flash)
  print('  Waiting for emulator to connect...');
  final deviceId = await _waitForAndroidDevice();

  // Wait for device to fully boot
  print('  Waiting for emulator to fully boot...');
  await _waitForAndroidBoot(deviceId);

  return deviceId;
}

/// Get full path to adb executable
String? _getAdbPath() {
  if (Platform.isWindows) {
    final localAppData = Platform.environment['LOCALAPPDATA'] ?? '';
    final path = '$localAppData\\Android\\Sdk\\platform-tools\\adb.exe';
    if (File(path).existsSync()) return path;
  } else if (Platform.isMacOS) {
    final home = Platform.environment['HOME'] ?? '';
    final path = '$home/Library/Android/sdk/platform-tools/adb';
    if (File(path).existsSync()) return path;
  }
  return null;
}

/// Run adb command silently (no CMD window on Windows)
Future<String> _runAdb(List<String> args) async {
  final adbPath = _getAdbPath();
  if (adbPath != null) {
    // Use full path - no shell needed, no CMD window
    final result = await Process.run(adbPath, args);
    return result.stdout as String;
  } else {
    // Fallback to PATH lookup (may show CMD window on Windows)
    final result = await Process.run('adb', args, runInShell: true);
    return result.stdout as String;
  }
}

/// Wait for an Android device to appear using adb
Future<String> _waitForAndroidDevice() async {
  final startTime = DateTime.now();

  while (DateTime.now().difference(startTime) < deviceTimeout) {
    final output = await _runAdb( ['devices']);
    final lines = output.split('\n');
    for (final line in lines) {
      // Format: "emulator-5554	device" or "emulator-5554	offline"
      if (line.contains('emulator') && line.contains('device')) {
        final deviceId = line.split('\t').first.trim();
        if (deviceId.isNotEmpty) {
          print('');
          return deviceId;
        }
      }
    }
    await Future.delayed(pollInterval);
    stdout.write('.');
  }

  throw Exception('Timeout waiting for Android device');
}

/// Wait for Android device to fully boot (sys.boot_completed = 1)
Future<void> _waitForAndroidBoot(String deviceId) async {
  final startTime = DateTime.now();
  final bootTimeout = Duration(seconds: 90);

  while (DateTime.now().difference(startTime) < bootTimeout) {
    final output = await _runAdb(
      ['-s', deviceId, 'shell', 'getprop', 'sys.boot_completed'],
    );

    if (output.trim() == '1') {
      print('');
      print('  Emulator fully booted!');
      // Give it a moment to settle
      await Future.delayed(Duration(seconds: 2));
      return;
    }

    await Future.delayed(pollInterval);
    stdout.write('.');
  }

  throw Exception('Timeout waiting for Android device to boot');
}

Future<String> _ensureIOSDevice() async {
  // Check if already running
  var devices = await _getRunningDevices();
  for (final device in devices) {
    final platform = device['targetPlatform'] as String? ?? '';
    final isEmulator = device['emulator'] as bool? ?? false;
    if (platform == 'ios' && isEmulator) {
      return device['id'] as String;
    }
  }

  // Get available simulators
  final simResult =
      await Process.run('xcrun', ['simctl', 'list', 'devices', '--json']);
  final simJson =
      jsonDecode(simResult.stdout as String) as Map<String, dynamic>;
  final simDevices = simJson['devices'] as Map<String, dynamic>;

  List<Map<String, String>> simulators = [];
  for (final runtime in simDevices.entries) {
    if (!runtime.key.contains('iOS')) continue;
    for (final device in runtime.value as List) {
      final deviceMap = device as Map<String, dynamic>;
      if (deviceMap['isAvailable'] == true) {
        final name = deviceMap['name'] as String;
        if (name.toLowerCase().contains('iphone')) {
          simulators.add({
            'name': name,
            'udid': deviceMap['udid'] as String,
          });
        }
      }
    }
  }

  String udid;
  String name;

  if (simulators.isEmpty) {
    // Create new simulator
    print('  Creating iOS simulator...');
    final runtimeResult =
        await Process.run('xcrun', ['simctl', 'list', 'runtimes', '--json']);
    final runtimeJson =
        jsonDecode(runtimeResult.stdout as String) as Map<String, dynamic>;
    final runtimes =
        (runtimeJson['runtimes'] as List).cast<Map<String, dynamic>>();

    final iosRuntime = runtimes.lastWhere(
      (r) => r['isAvailable'] == true && (r['name'] as String).contains('iOS'),
      orElse: () => throw Exception('No iOS runtime available'),
    );

    final createResult = await Process.run('xcrun', [
      'simctl',
      'create',
      'Flutter iPhone',
      'iPhone 16 Pro',
      iosRuntime['identifier'] as String,
    ]);

    if (createResult.exitCode != 0) {
      throw Exception('Failed to create simulator: ${createResult.stderr}');
    }

    udid = (createResult.stdout as String).trim();
    name = 'Flutter iPhone';
  } else {
    udid = simulators.first['udid']!;
    name = simulators.first['name']!;
  }

  // Boot simulator
  print('  Launching $name...');
  await Process.run('xcrun', ['simctl', 'boot', udid]);
  await Process.run('open', ['-a', 'Simulator']);

  // Wait for device
  return await _waitForDevice(
    'iOS',
    () async {
      final devices = await _getRunningDevices();
      for (final device in devices) {
        final platform = device['targetPlatform'] as String? ?? '';
        final isEmulator = device['emulator'] as bool? ?? false;
        if (platform == 'ios' && isEmulator) {
          return device['id'] as String?;
        }
      }
      return null;
    },
  );
}

Future<String> _waitForDevice(
  String platform,
  Future<String?> Function() getDeviceId,
) async {
  final startTime = DateTime.now();
  print('  Waiting for $platform device (timeout: ${deviceTimeout.inSeconds}s)...');

  var attempt = 0;
  while (DateTime.now().difference(startTime) < deviceTimeout) {
    final id = await getDeviceId();
    if (id != null) {
      print('\n  Device found: $id');
      return id;
    }
    await Future.delayed(pollInterval);
    attempt++;
    if (attempt % 5 == 0) {
      print('  Still waiting... (${DateTime.now().difference(startTime).inSeconds}s)');
    } else {
      stdout.write('.');
    }
  }

  throw Exception('Timeout waiting for $platform device');
}

// ============================================================================
// VS Code Configuration
// ============================================================================

Future<void> _generateVSCodeConfig({
  required String env,
  required String mode,
  required String platform,
  String? androidId,
  String? iosId,
}) async {
  final vscodeDir = Directory('.vscode');
  if (!vscodeDir.existsSync()) {
    vscodeDir.createSync();
  }

  // Build configurations based on requested platform only
  final configurations = <Map<String, dynamic>>[];
  List<Map<String, dynamic>>? compounds;

  if (platform == 'android') {
    // Only Android config
    configurations.add({
      'name': 'Flutter (Android)',
      'type': 'dart',
      'request': 'launch',
      'deviceId': androidId!,
      'args': ['--dart-define=ENV=$env'],
      'flutterMode': mode,
    });
  } else if (platform == 'ios') {
    // Only iOS config
    configurations.add({
      'name': 'Flutter (iOS)',
      'type': 'dart',
      'request': 'launch',
      'deviceId': iosId ?? 'iPhone',
      'args': ['--dart-define=ENV=$env'],
      'flutterMode': mode,
    });
  } else if (platform == 'both') {
    // Both platforms - need hidden configs for compound
    configurations.add({
      'name': '_Android',
      'type': 'dart',
      'request': 'launch',
      'presentation': {'hidden': true},
      'deviceId': androidId!,
      'args': ['--dart-define=ENV=$env'],
      'flutterMode': mode,
    });
    configurations.add({
      'name': '_iOS',
      'type': 'dart',
      'request': 'launch',
      'presentation': {'hidden': true},
      'deviceId': iosId ?? 'iPhone',
      'args': ['--dart-define=ENV=$env'],
      'flutterMode': mode,
    });
    compounds = [
      {
        'name': 'Flutter (Both Platforms)',
        'configurations': ['_Android', '_iOS'],
        'stopAll': true,
      },
    ];
  }

  final launchJson = <String, dynamic>{
    'version': '0.2.0',
    'configurations': configurations,
  };
  if (compounds != null) {
    launchJson['compounds'] = compounds;
  }

  final encoder = JsonEncoder.withIndent('  ');
  File('.vscode/launch.json')
      .writeAsStringSync('${encoder.convert(launchJson)}\n');

  final configName = platform == 'both'
      ? 'Flutter (Both Platforms)'
      : platform == 'ios'
          ? 'Flutter (iOS)'
          : 'Flutter (Android)';
  print('  Generated .vscode/launch.json');
  print('  Config: $configName (ENV=$env, mode=$mode)');
}

// ============================================================================
// VS Code Launch
// ============================================================================

Future<void> _launchVSCodeDebug(String platform) async {
  if (Platform.isMacOS) {
    // Use AppleScript to trigger F5 in VS Code
    await Process.run('osascript', [
      '-e', 'tell application "Visual Studio Code" to activate',
      '-e', 'delay 0.5',
      '-e', 'tell application "System Events" to key code 96', // F5
    ]);
  } else if (Platform.isLinux) {
    // Use xdotool on Linux
    await Process.run('bash', [
      '-c',
      '''
      wmctrl -a "Visual Studio Code" 2>/dev/null || code .
      sleep 0.5
      xdotool key F5
    '''
    ]);
  } else if (Platform.isWindows) {
    // Use VBScript on Windows (native, no escaping issues)
    final vbsScript = '''
Set WshShell = CreateObject("WScript.Shell")
WshShell.AppActivate "Visual Studio Code"
WScript.Sleep 500
WshShell.SendKeys "{F5}"
''';
    final tempDir = Platform.environment['TEMP'] ?? r'C:\Windows\Temp';
    final vbsFile = File('$tempDir\\flutter_launch_vscode.vbs');
    vbsFile.writeAsStringSync(vbsScript);
    await Process.run('wscript', [vbsFile.path]);
    vbsFile.deleteSync();
  } else {
    print('  Note: Auto-launch not supported on this platform.');
    print('  Please press F5 in VS Code to start debugging.');
  }
}
