import 'package:flare_flutter_sdk/flare_flutter_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ---- FlareNetwork ----

  group('FlareNetwork', () {
    test('has exactly four networks', () {
      expect(FlareNetwork.values.length, 4);
    });

    test('includes flare, songbird, coston2, and coston', () {
      expect(FlareNetwork.values, contains(FlareNetwork.flare));
      expect(FlareNetwork.values, contains(FlareNetwork.songbird));
      expect(FlareNetwork.values, contains(FlareNetwork.coston2));
      expect(FlareNetwork.values, contains(FlareNetwork.coston));
    });
  });

  // ---- FlareException ----

  group('FlareException', () {
    test('toString includes the message', () {
      final exception = FlareException('something went wrong');
      expect(exception.toString(), 'FlareException: something went wrong');
    });
  });
}
