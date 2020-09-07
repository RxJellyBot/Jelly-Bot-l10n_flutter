import 'dart:async';
import 'package:flutter/services.dart';
import 'package:l10n/l10n.dart';
import 'package:l10n_flutter/src/platform_flutter.dart';

class FlutterResourceProvider extends BaseResourceProvider
    with FlutterPlatformProvider {
  final AssetBundle assetBundle;
  FlutterResourceProvider({AssetBundle asset, LocaleProvider locale})
      : assetBundle = asset ?? rootBundle,
        super(locale);

  @override
  Future<String> readAsString(String key) {
    return assetBundle.loadString('res@${locale.CODE}/$key');
  }
}

class FlutterResourceProviderWithFallback extends FlutterResourceProvider {
  final ResourceProvider fallback;
  FlutterResourceProviderWithFallback(this.fallback,
      {AssetBundle asset, LocaleProvider locale})
      : super(asset: asset, locale: locale);

  @override
  Future<String> readAsString(String key) {
    try {
      return super.readAsString(key);
    } on Error catch (_) {
      return fallback.readAsString(key);
    }
  }

  @override
  String getString(int key) => super.getString(key) ?? fallback.getString(key);
}
