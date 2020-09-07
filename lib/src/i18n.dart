import 'package:flutter/services.dart';
import 'package:l10n/l10n.dart';
import 'package:l10n_flutter/l10n_flutter.dart';

class I18n {
  static AssetBundle _usingAsset;
  static ResourceProvider _fallbackRes;
  static ResourceProvider _usingRes;

  static ResourceProvider get resource => _usingRes ?? _fallbackRes;

  I18n._() {
    throw UnsupportedError('I18n is not support to instantiate');
  }

  static Future<void> initialize(
      {AssetBundle assetBundle,
      LocaleProvider fallbackLocale,
      LocaleProvider startupLocale}) async {
    fallbackLocale ??= LocaleProvider.global;
    _usingAsset = assetBundle;
    _fallbackRes = FlutterResourceProvider(
        locale: fallbackLocale ?? LocaleProvider.global, asset: _usingAsset);
    await _fallbackRes.initialize();
    if (startupLocale != null && !identical(startupLocale, fallbackLocale)) {
      await switchLocale(startupLocale);
    }
  }

  static Future<void> switchLocale(LocaleProvider locale) async {
    if (identical(locale, _fallbackRes.locale) || locale == null) {
      _usingRes = null;
      return;
    }
    if (!identical(locale, _usingRes?.locale)) {
      _usingRes = FlutterResourceProviderWithFallback(_fallbackRes,
          locale: locale, asset: _usingAsset);
      await _usingRes.initialize();
    }
  }
}
