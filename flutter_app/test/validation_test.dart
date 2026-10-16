import 'package:flutter_test/flutter_test.dart';
import 'package:movie_imposter/domain/validation.dart';

void main() {
  group('Player Validation', () {
    test('rejects fewer than 3 players', () {
      expect(validatePlayers(['Alice', 'Bob']).isValid, isFalse);
      expect(validatePlayers(['Alice']).isValid, isFalse);
      expect(validatePlayers([]).isValid, isFalse);
    });

    test('accepts unlimited players (e.g. 15, 20, 50 players)', () {
      final fifty = List.generate(50, (i) => 'Player ${i + 1}');
      expect(validatePlayers(fifty).isValid, isTrue);
    });

    test('automatically resolves empty or whitespace-only names to Player X', () {
      final resolved = resolvePlayerNames(['Alice', '', '   ', 'David']);
      expect(resolved, equals(['Alice', 'Player 2', 'Player 3', 'David']));

      // Valid when resolved names don't conflict
      expect(validatePlayers(['Alice', '', 'Charlie']).isValid, isTrue);
    });

    test('detects duplicate names after resolution ignoring case', () {
      // Explicit duplicate
      expect(validatePlayers(['Alice', 'alice', 'Charlie']).isValid, isFalse);
      // Conflict when user explicitly typed "Player 2" and left row 2 blank (resolving to Player 2)
      expect(validatePlayers(['Player 2', '', 'Charlie']).isValid, isFalse);
    });

    test('accepts valid distinct names between 3 and 10 players', () {
      final validThree = validatePlayers(['Venkatesh', 'Nagarjuna', 'Chiranjeevi']);
      expect(validThree.isValid, isTrue);

      final validTen = List.generate(10, (i) => 'Player ${i + 1}');
      expect(validatePlayers(validTen).isValid, isTrue);
    });
  });
}
