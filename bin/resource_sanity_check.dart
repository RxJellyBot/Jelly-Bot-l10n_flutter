import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

class ResourcePathConfiguration {
  final String stringPath;
  ResourcePathConfiguration.fromJson(Map<String, dynamic> json)
      : stringPath = json['stringPath'];
}

class ResourceSanityCheckConfiguration {
  final Map<String, ResourcePathConfiguration> localizedConfig;
  String defaultLocale;
  ResourceSanityCheckConfiguration.fromJson(Map<String, dynamic> json)
      : localizedConfig = _fromJson(json['config']),
        defaultLocale = json['default'];

  static Map<String, ResourcePathConfiguration> _fromJson(
      Map<String, dynamic> json) {
    return json.map((key, value) {
      return MapEntry(key, ResourcePathConfiguration.fromJson(value));
    });
  }
}

Map<String, dynamic> readAsJsonOrError(String path) {
  var file = File(path);
  // Check file existance
  if (!file.existsSync()) {
    error$isNotExists('file $path');
  }
  return jsonDecode(file.readAsStringSync());
}

void error$isNotExists(String msg) {
  stderr.writeln('error: $msg is not exists');
  exit(1);
}

void error$isNotConfigured(String msg) {
  stderr.writeln('error: $msg is not configured');
  exit(1);
}

void sanityCheck(ResourceSanityCheckConfiguration cfg, String workingDir) {
  var resDefault = cfg.localizedConfig[cfg.defaultLocale];
  if (resDefault == null) {
    error$isNotConfigured('default locale ${cfg.defaultLocale}');
  }
  cfg.localizedConfig.remove(cfg.defaultLocale);

  var err = StringBuffer();
  sanityCheck$string(cfg, resDefault, workingDir, err);

  if (err.length > 0) {
    stderr.write(err);
    exit(1);
  }
}

void sanityCheck$string(ResourceSanityCheckConfiguration cfg,
    ResourcePathConfiguration compareTo, String workingDir, StringBuffer err) {
  var compareToPath =
      path.relative(path.join(workingDir, compareTo.stringPath));
  var compareToJson = readAsJsonOrError(compareToPath);
  var from = cfg.localizedConfig.map((key, value) {
    var compareFromPath =
        path.relative(path.join(workingDir, value.stringPath));
    return MapEntry(compareFromPath, readAsJsonOrError(compareFromPath));
  });

  // check all json keys and values
  for (var jsonEntry in [
    MapEntry(compareToPath, compareToJson),
    ...from.entries
  ]) {
    for (var entry in jsonEntry.value.entries) {
      if (int.tryParse(entry.key) == null) {
        err.writeln(
            'error: ${jsonEntry.key}: key ${entry.key} must be integer');
        continue;
      }
      if (entry.value is! String) {
        err.writeln(
            'error: ${jsonEntry.key}: value of ${entry.key} must be string');
      }
    }
  }

  // check all existance
  for (var entry in compareToJson.entries) {
    for (var fromEntry in from.entries) {
      if (!fromEntry.value.containsKey(entry.key)) {
        err.writeln(
            'error: ${fromEntry.key}: missing key ${entry.key} which list in $compareToPath');
      }
      for (var elementEntry in fromEntry.value.entries) {
        if (!compareToJson.containsKey(elementEntry.key)) {
          err.writeln(
              'error: $compareToPath: missing key ${elementEntry.key} which list in ${fromEntry.key}');
        }
      }
    }
  }
}

void main(List<String> args) {
  const String _usage =
      'arguments usage:\n\tpath_to_resource_configuration.json [locale-to-override-default]';

  // Message arg parse errors
  if (args.isEmpty) {
    stderr.writeln(
        'error: resource configuration path argument required.\n$_usage');
    exit(1);
  }

  var resCfgPath = args[0];
  // Make path absolute
  if (path.isRelative(resCfgPath)) {
    resCfgPath = path.absolute(resCfgPath);
  }

  var resCfg =
      ResourceSanityCheckConfiguration.fromJson(readAsJsonOrError(resCfgPath));

  if (args.length > 1) {
    resCfg.defaultLocale = args[1];
  }

  sanityCheck(resCfg, path.dirname(resCfgPath));
}
