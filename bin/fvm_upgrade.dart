// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

void main() async {
  final string = await http.read(
    Uri.parse(
      'https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json',
    ),
  );

  final json = jsonDecode(string) as Map<String, dynamic>;
  final latest = json['current_release']['stable'] as String;
  final releases = (json['releases'] as List).cast<Map<String, dynamic>>();
  final latestRelease =
      releases.firstWhere((release) => release['hash'] == latest);
  final latestVersion = latestRelease['version'] as String;
  print('Latest Flutter version: $latestVersion');

  final fvmConfigs = Directory.current
      .listSync(recursive: true)
      .whereType<File>()
      .where((e) => e.path.endsWith('fvm_config.json'));

  print('Found ${fvmConfigs.length} fvm_config.json file(s):');
  for (final config in fvmConfigs) {
    print('  ${config.path}');
  }

  for (final config in fvmConfigs) {
    final string = config.readAsStringSync();
    final json = jsonDecode(string) as Map<String, dynamic>;
    json['flutterSdkVersion'] = latestVersion;
    config.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(json));

    print('Updated ${config.path}');
  }
}
