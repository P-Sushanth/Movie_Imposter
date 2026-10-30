const List<String> hangmanLetters = ['H', 'A', 'N', 'G', 'M', 'A', 'N'];
const int maxStrikes = 7;

enum RoundOutcomeReason {
  guessedWithoutClues,
  guessedWithClues,
  strikesExpired,
}

enum HangmanTeamRole {
  teamA,
  teamB,
}

class HangmanState {
  final String teamAName;
  final String teamBName;
  final HangmanTeamRole settingTeam;
  final String secretWord;
  final List<String> clues;
  final Set<String> guessedLetters;
  final bool cluesViewed;
  final int scoreTeamA;
  final int scoreTeamB;

  const HangmanState({
    required this.teamAName,
    required this.teamBName,
    required this.settingTeam,
    required this.secretWord,
    required this.clues,
    required this.guessedLetters,
    required this.cluesViewed,
    required this.scoreTeamA,
    required this.scoreTeamB,
  });

  HangmanTeamRole get guessingTeam =>
      settingTeam == HangmanTeamRole.teamA ? HangmanTeamRole.teamB : HangmanTeamRole.teamA;

  String get settingTeamName =>
      settingTeam == HangmanTeamRole.teamA ? teamAName : teamBName;

  String get guessingTeamName =>
      settingTeam == HangmanTeamRole.teamA ? teamBName : teamAName;

  HangmanState copyWith({
    String? teamAName,
    String? teamBName,
    HangmanTeamRole? settingTeam,
    String? secretWord,
    List<String>? clues,
    Set<String>? guessedLetters,
    bool? cluesViewed,
    int? scoreTeamA,
    int? scoreTeamB,
  }) {
    return HangmanState(
      teamAName: teamAName ?? this.teamAName,
      teamBName: teamBName ?? this.teamBName,
      settingTeam: settingTeam ?? this.settingTeam,
      secretWord: secretWord ?? this.secretWord,
      clues: clues ?? this.clues,
      guessedLetters: guessedLetters ?? this.guessedLetters,
      cluesViewed: cluesViewed ?? this.cluesViewed,
      scoreTeamA: scoreTeamA ?? this.scoreTeamA,
      scoreTeamB: scoreTeamB ?? this.scoreTeamB,
    );
  }
}

class RoundScoreResult {
  final HangmanTeamRole winner;
  final int pointsAwarded;
  final RoundOutcomeReason reason;
  final int updatedScoreTeamA;
  final int updatedScoreTeamB;

  const RoundScoreResult({
    required this.winner,
    required this.pointsAwarded,
    required this.reason,
    required this.updatedScoreTeamA,
    required this.updatedScoreTeamB,
  });
}

bool isLetterOrDigit(String char) {
  if (char.isEmpty) return false;
  final code = char.codeUnitAt(0);
  // '0'-'9' (48-57), 'A'-'Z' (65-90), 'a'-'z' (97-122)
  return (code >= 48 && code <= 57) ||
      (code >= 65 && code <= 90) ||
      (code >= 97 && code <= 122);
}

String normalizeWord(String word) {
  return word.trim().toUpperCase();
}

List<String> getMaskedCharacters(String secretWord, Set<String> guessedLetters) {
  final normalized = normalizeWord(secretWord);
  final upperGuesses = guessedLetters.map((c) => c.toUpperCase()).toSet();
  final chars = <String>[];

  for (int i = 0; i < normalized.length; i++) {
    final ch = normalized[i];
    if (isLetterOrDigit(ch)) {
      chars.add(upperGuesses.contains(ch) ? ch : '_');
    } else {
      chars.add(ch);
    }
  }
  return chars;
}

List<String> getWrongGuesses(String secretWord, Set<String> guessedLetters) {
  final normalized = normalizeWord(secretWord);
  final upperGuesses = guessedLetters.map((c) => c.toUpperCase()).toSet();
  final wrong = <String>[];

  for (final ch in upperGuesses) {
    if (isLetterOrDigit(ch) && !normalized.contains(ch)) {
      wrong.add(ch);
    }
  }
  return wrong;
}

int getStrikeCount(String secretWord, Set<String> guessedLetters) {
  final count = getWrongGuesses(secretWord, guessedLetters).length;
  return count > maxStrikes ? maxStrikes : count;
}

bool isWordGuessed(String secretWord, Set<String> guessedLetters) {
  final normalized = normalizeWord(secretWord);
  if (normalized.isEmpty) return false;
  final upperGuesses = guessedLetters.map((c) => c.toUpperCase()).toSet();

  for (int i = 0; i < normalized.length; i++) {
    final ch = normalized[i];
    if (isLetterOrDigit(ch) && !upperGuesses.contains(ch)) {
      return false;
    }
  }
  return true;
}

bool isHangmanExpired(String secretWord, Set<String> guessedLetters) {
  return getStrikeCount(secretWord, guessedLetters) >= maxStrikes;
}

bool isRoundOver(String secretWord, Set<String> guessedLetters) {
  return isWordGuessed(secretWord, guessedLetters) ||
      isHangmanExpired(secretWord, guessedLetters);
}

RoundScoreResult calculateRoundOutcome(HangmanState state) {
  final guessed = isWordGuessed(state.secretWord, state.guessedLetters);
  final guessingTeam = state.guessingTeam;
  final settingTeam = state.settingTeam;

  if (guessed) {
    final points = state.cluesViewed ? 1 : 2;
    final reason = state.cluesViewed
        ? RoundOutcomeReason.guessedWithClues
        : RoundOutcomeReason.guessedWithoutClues;
    return RoundScoreResult(
      winner: guessingTeam,
      pointsAwarded: points,
      reason: reason,
      updatedScoreTeamA:
          state.scoreTeamA + (guessingTeam == HangmanTeamRole.teamA ? points : 0),
      updatedScoreTeamB:
          state.scoreTeamB + (guessingTeam == HangmanTeamRole.teamB ? points : 0),
    );
  }

  // 7 strikes expired -> setting team gets +1 point
  return RoundScoreResult(
    winner: settingTeam,
    pointsAwarded: 1,
    reason: RoundOutcomeReason.strikesExpired,
    updatedScoreTeamA:
        state.scoreTeamA + (settingTeam == HangmanTeamRole.teamA ? 1 : 0),
    updatedScoreTeamB:
        state.scoreTeamB + (settingTeam == HangmanTeamRole.teamB ? 1 : 0),
  );
}

HangmanState createNextHangmanRound(
  HangmanState previousState,
  RoundScoreResult outcome,
) {
  return HangmanState(
    teamAName: previousState.teamAName,
    teamBName: previousState.teamBName,
    settingTeam: previousState.settingTeam == HangmanTeamRole.teamA
        ? HangmanTeamRole.teamB
        : HangmanTeamRole.teamA,
    secretWord: '',
    clues: const [],
    guessedLetters: const <String>{},
    cluesViewed: false,
    scoreTeamA: outcome.updatedScoreTeamA,
    scoreTeamB: outcome.updatedScoreTeamB,
  );
}

