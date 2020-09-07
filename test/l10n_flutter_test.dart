import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:l10n_flutter/l10n_flutter.dart';
import 'assetBundle_test.dart';

void main() {
  test('test string resource', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    await I18n.initialize(
        assetBundle: TestAssetBundle(),
        fallbackLocale: LocaleProvider.desired('en-us'),
        startupLocale: LocaleProvider.desired('zh-tw'));

    expect(I18n.resource.getString(12345), '黯陰羊老雞排');
    expect(I18n.resource.getString(23456), 'hahhhhh!?');
    expect(I18n.resource.format(34567, {'key': 123.456}), '超營養雞排 123.46');
    expect(
        I18n.resource.format(45678, {'key': DateTime(2020, 9, 20, 12, 34, 56)}),
        '12:34:56 hehehe~');
  });
}
