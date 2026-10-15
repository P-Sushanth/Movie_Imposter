import 'package:flutter_test/flutter_test.dart';
import 'package:movie_imposter/services/update_service.dart';

void main() {
  group('Update Version Comparison', () {
    test('detects when latest version is newer', () {
      expect(isVersionNewer('1.0.1', '1.0.0'), isTrue);
      expect(isVersionNewer('v1.0.1', '1.0.0'), isTrue);
      expect(isVersionNewer('1.1.0', '1.0.9'), isTrue);
      expect(isVersionNewer('2.0.0', '1.9.9'), isTrue);
      expect(isVersionNewer('v2.0.0', 'v1.9.9'), isTrue);
    });

    test('detects when current version is already latest or newer', () {
      expect(isVersionNewer('1.0.0', '1.0.0'), isFalse);
      expect(isVersionNewer('v1.0.0', '1.0.0'), isFalse);
      expect(isVersionNewer('1.0.0', '1.0.1'), isFalse);
      expect(isVersionNewer('0.9.9', '1.0.0'), isFalse);
    });

    test('handles versions with different part lengths', () {
      expect(isVersionNewer('1.0.1.1', '1.0.1'), isTrue);
      expect(isVersionNewer('1.0', '1.0.0'), isFalse);
    });
  });
}
