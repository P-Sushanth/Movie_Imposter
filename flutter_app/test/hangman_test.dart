import 'package:flutter_test/flutter_test.dart';
import 'package:movie_imposter/domain/hangman.dart';

void main() {
  group('Hangman Domain Engine (Dart)', () {
    test('masks unguessed alphanumeric characters as underscores', () {
      final masked = getMaskedCharacters('DEVARA', {'D', 'A'});
      expect(masked.join(''), equals('D__A_A'));
    });

    test('automatically reveals spaces, dashes, colons, and exclamation marks', () {
      final masked = getMaskedCharacters('RRR: Part 1 - Fire!', {'R'});
      expect(masked.join(''), equals('RRR: __R_ _ - __R_!'));
    });

    test('handles numeric digits properly', () {
      final masked = getMaskedCharacters('KGF 2', {'2'});
      expect(masked.join(''), equals('___ 2'));
    });

    test('identifies wrong guesses correctly', () {
      final wrong = getWrongGuesses('BAAHUBALI', {'B', 'A', 'Z', 'X'});
      wrong.sort();
      expect(wrong, equals(['X', 'Z']));
    });

    test('caps strikes at maxStrikes (7)', () {
      final wrongGuesses = {'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'};
      final count = getStrikeCount('JAVA', wrongGuesses);
      expect(count, equals(7));
    });

    test('detects when the word has been completely guessed', () {
      expect(isWordGuessed('PUSHPA', {'P', 'U', 'S', 'H', 'A'}), isTrue);
      expect(isWordGuessed('PUSHPA', {'P', 'U', 'S', 'H'}), isFalse);
    });

    test('detects when 7 strikes are reached', () {
      final sevenWrong = {'B', 'C', 'D', 'F', 'G', 'H', 'J'};
      expect(isHangmanExpired('AAA', sevenWrong), isTrue);
      expect(isRoundOver('AAA', sevenWrong), isTrue);
    });

    const baseState = HangmanState(
      teamAName: 'Team Popcorn',
      teamBName: 'Team Cinema',
      settingTeam: HangmanTeamRole.teamA,
      secretWord: 'INTERSTELLAR',
      clues: ['Sci-fi film', 'Nolan', 'Black hole'],
      guessedLetters: {'I', 'N', 'T', 'E', 'R', 'S', 'L', 'A'},
      cluesViewed: false,
      scoreTeamA: 2,
      scoreTeamB: 1,
    );

    test('awards +2 Points to guessing team if solved without looking at clues', () {
      final outcome = calculateRoundOutcome(baseState);
      expect(outcome.winner, equals(HangmanTeamRole.teamB));
      expect(outcome.pointsAwarded, equals(2));
      expect(outcome.reason, equals(RoundOutcomeReason.guessedWithoutClues));
      expect(outcome.updatedScoreTeamA, equals(2));
      expect(outcome.updatedScoreTeamB, equals(3));
    });

    test('awards +1 Point to guessing team if clues were opened', () {
      final stateWithClues = baseState.copyWith(cluesViewed: true);
      final outcome = calculateRoundOutcome(stateWithClues);
      expect(outcome.winner, equals(HangmanTeamRole.teamB));
      expect(outcome.pointsAwarded, equals(1));
      expect(outcome.reason, equals(RoundOutcomeReason.guessedWithClues));
      expect(outcome.updatedScoreTeamA, equals(2));
      expect(outcome.updatedScoreTeamB, equals(2));
    });

    test('awards +1 Point to setting team when 7 strikes expire', () {
      final expiredState = baseState.copyWith(
        guessedLetters: {'Q', 'W', 'Y', 'U', 'O', 'P', 'Z'},
      );
      final outcome = calculateRoundOutcome(expiredState);
      expect(outcome.winner, equals(HangmanTeamRole.teamA));
      expect(outcome.pointsAwarded, equals(1));
      expect(outcome.reason, equals(RoundOutcomeReason.strikesExpired));
      expect(outcome.updatedScoreTeamA, equals(3));
      expect(outcome.updatedScoreTeamB, equals(1));
    });

    test('swaps setting and guessing teams for next round and preserves scores', () {
      final outcome = calculateRoundOutcome(baseState);
      final nextRound = createNextHangmanRound(baseState, outcome);

      expect(nextRound.settingTeam, equals(HangmanTeamRole.teamB));
      expect(nextRound.scoreTeamA, equals(2));
      expect(nextRound.scoreTeamB, equals(3));
      expect(nextRound.secretWord, isEmpty);
      expect(nextRound.clues, isEmpty);
      expect(nextRound.guessedLetters, isEmpty);
      expect(nextRound.cluesViewed, isFalse);
    });
  });
}

