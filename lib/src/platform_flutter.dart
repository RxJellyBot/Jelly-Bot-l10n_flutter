import 'package:flutter/foundation.dart' as flutter;
import 'package:l10n/l10n.dart';

mixin FlutterPlatformProvider on PlatformProvider {
  @override
  Future<TResult> compute<TArg, TResult>(
          TResult Function(TArg p1) heavyWork, TArg arg) =>
      flutter.compute(heavyWork, arg);
}
