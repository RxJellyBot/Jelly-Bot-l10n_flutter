import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:l10n_flutter/l10n_flutter.dart';
import 'assetBundle.dart';

void main() {
  test('test string resource', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    await I18n.initialize(
        assetBundle: TestAssetBundle(),
        fallbackLocale: LocaleProvider.desired('en-us'),
        startupLocale: LocaleProvider.desired('zh-tw'));

    // getString with setup locale
    expect(I18n.resource.getString(12345), '黯陰羊老雞排');

    // getString with fallback locale
    expect(I18n.resource.getString(23456), 'hahhhhh!?');

    // format with setup locale
    expect(I18n.resource.format(34567, {'key': 123.456}), '超營養雞排 123.46');

    // format with fallback locale
    expect(
        I18n.resource.format(45678, {'key': DateTime(2020, 9, 20, 12, 34, 56)}),
        '12:34:56 hehehe~');

    // set locale to en-us
    await I18n.switchLocale(LocaleProvider.desired('en-us'));

    // getString with setup locale
    expect(I18n.resource.getString(12345), 'first blood');
    // format with setup locale
    expect(I18n.resource.format(34567, {'key': 654.321}), '654.32 mdfk');
  });
}
