import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prokopa/src/core/constants/brand_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('brand constants contain expected primary color', () {
    expect(BrandConstants.primaryColor, const Color(0xFF3949AB));
  });

  test('flutter asset bundle can load light logo asset', () async {
    final content = await rootBundle.loadString(BrandConstants.logoLight);
    expect(content.isNotEmpty, isTrue);
    expect(content.contains('<svg'), isTrue);
    expect(content.contains('#3949ab'), isTrue);
  });

  test('flutter asset bundle can load dark logo asset', () async {
    final content = await rootBundle.loadString(BrandConstants.logoDark);
    expect(content.isNotEmpty, isTrue);
    expect(content.contains('<svg'), isTrue);
    expect(content.contains('#3949ab'), isTrue);
  });
}
