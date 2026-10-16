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

  group('Release Notes Feature Parser', () {
    test('parses markdown bullets and removes headers and bold tags', () {
      const notes = '''
### What's New in v1.0.10:
- ♾️ **Unlimited player count**: Play with any number of friends
- 🎨 **Warm off-white theme**: Easy on eyes
- ⚡ **Instant In-App Updates**
---
Enjoy the game!
''';
      final features = parseReleaseFeatures(notes);
      expect(features.length, 4);
      expect(features[0], '♾️ Unlimited player count: Play with any number of friends');
      expect(features[1], '🎨 Warm off-white theme: Easy on eyes');
      expect(features[2], '⚡ Instant In-App Updates');
      expect(features[3], 'Enjoy the game!');
    });

    test('provides clean defaults when release notes are null or empty', () {
      expect(parseReleaseFeatures(null).isNotEmpty, isTrue);
      expect(parseReleaseFeatures('').isNotEmpty, isTrue);
      expect(parseReleaseFeatures('   \n\n  ').isNotEmpty, isTrue);
    });

    test('supports bullet asterisks and numbered lists', () {
      const notes = '''
* New sound effect
* Improved card layout
1. Bug fix for timers
''';
      final features = parseReleaseFeatures(notes);
      expect(features, [
        'New sound effect',
        'Improved card layout',
        'Bug fix for timers',
      ]);
    });
  });
}

