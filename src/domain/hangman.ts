export interface HangmanState {
  teamAName: string;
  teamBName: string;
  settingTeam: 'teamA' | 'teamB'; // Which team sets the word
  secretWord: string; // Normalized uppercase secret word/phrase
  clues: string[]; // Up to 3 clues
  guessedLetters: Set<string>; // Guessed alphanumeric characters (uppercase)
  cluesViewed: boolean; // Whether guessing team opened the clues modal
  scoreTeamA: number; // Session score for Team A
  scoreTeamB: number; // Session score for Team B
}

export const HANGMAN_LETTERS = ['H', 'A', 'N', 'G', 'M', 'A', 'N'] as const;
export const MAX_STRIKES = 7;

/**
 * Checks if a character is an alphanumeric letter or digit.
 */
export function isLetterOrDigit(char: string): boolean {
  return /^[A-Z0-9]$/i.test(char);
}

/**
 * Normalizes input word/phrase by trimming and converting to uppercase.
 */
export function normalizeWord(word: string): string {
  return word.trim().toUpperCase();
}

/**
 * Masks characters in the word: unguessed letters/digits are '_',
 * while spaces, punctuation, and already guessed characters are revealed.
 */
export function getMaskedCharacters(
  secretWord: string,
  guessedLetters: Set<string> | string[]
): string[] {
  const guessedSet = guessedLetters instanceof Set ? guessedLetters : new Set(guessedLetters);
  const normalized = normalizeWord(secretWord);
  const chars: string[] = [];

  for (let i = 0; i < normalized.length; i++) {
    const ch = normalized[i];
    if (isLetterOrDigit(ch)) {
      chars.push(guessedSet.has(ch) ? ch : '_');
    } else {
      // Spaces, dashes, colons, apostrophes are auto-revealed
      chars.push(ch);
    }
  }
  return chars;
}

/**
 * Returns an array of guessed characters that do NOT exist in the secret word.
 */
export function getWrongGuesses(
  secretWord: string,
  guessedLetters: Set<string> | string[]
): string[] {
  const guessedSet = guessedLetters instanceof Set ? guessedLetters : new Set(guessedLetters);
  const normalized = normalizeWord(secretWord);
  const wrong: string[] = [];

  for (const ch of guessedSet) {
    if (isLetterOrDigit(ch) && !normalized.includes(ch)) {
      wrong.push(ch);
    }
  }
  return wrong;
}

/**
 * Calculates current strike count capped at MAX_STRIKES (7).
 */
export function getStrikeCount(
  secretWord: string,
  guessedLetters: Set<string> | string[]
): number {
  return Math.min(MAX_STRIKES, getWrongGuesses(secretWord, guessedLetters).length);
}

/**
 * Returns true if all alphanumeric characters in secretWord have been guessed.
 */
export function isWordGuessed(
  secretWord: string,
  guessedLetters: Set<string> | string[]
): boolean {
  const guessedSet = guessedLetters instanceof Set ? guessedLetters : new Set(guessedLetters);
  const normalized = normalizeWord(secretWord);
  if (!normalized) return false;

  for (let i = 0; i < normalized.length; i++) {
    const ch = normalized[i];
    if (isLetterOrDigit(ch) && !guessedSet.has(ch)) {
      return false;
    }
  }
  return true;
}

/**
 * Returns true if all 7 HANGMAN strikes have been exhausted.
 */
export function isHangmanExpired(
  secretWord: string,
  guessedLetters: Set<string> | string[]
): boolean {
  return getStrikeCount(secretWord, guessedLetters) >= MAX_STRIKES;
}

/**
 * Checks if the round has finished (either word guessed or strikes expired).
 */
export function isRoundOver(
  secretWord: string,
  guessedLetters: Set<string> | string[]
): boolean {
  return isWordGuessed(secretWord, guessedLetters) || isHangmanExpired(secretWord, guessedLetters);
}

export interface RoundScoreResult {
  winner: 'teamA' | 'teamB';
  pointsAwarded: number;
  reason: 'GUESSED_WITHOUT_CLUES' | 'GUESSED_WITH_CLUES' | 'STRIKES_EXPIRED';
  updatedScoreTeamA: number;
  updatedScoreTeamB: number;
}

/**
 * Calculates outcome and updated session scores:
 * - Solved without viewing clues: Guessing team earns +2 points.
 * - Solved with clues viewed: Guessing team earns +1 point.
 * - 7 strikes reached: Setting team earns +1 point.
 */
export function calculateRoundOutcome(state: HangmanState): RoundScoreResult {
  const guessed = isWordGuessed(state.secretWord, state.guessedLetters);
  const guessingTeam = state.settingTeam === 'teamA' ? 'teamB' : 'teamA';
  const settingTeam = state.settingTeam;

  if (guessed) {
    const points = state.cluesViewed ? 1 : 2;
    const reason = state.cluesViewed ? 'GUESSED_WITH_CLUES' : 'GUESSED_WITHOUT_CLUES';
    return {
      winner: guessingTeam,
      pointsAwarded: points,
      reason,
      updatedScoreTeamA: state.scoreTeamA + (guessingTeam === 'teamA' ? points : 0),
      updatedScoreTeamB: state.scoreTeamB + (guessingTeam === 'teamB' ? points : 0),
    };
  }

  // 7 strikes expired -> setting team gets +1 point
  return {
    winner: settingTeam,
    pointsAwarded: 1,
    reason: 'STRIKES_EXPIRED',
    updatedScoreTeamA: state.scoreTeamA + (settingTeam === 'teamA' ? 1 : 0),
    updatedScoreTeamB: state.scoreTeamB + (settingTeam === 'teamB' ? 1 : 0),
  };
}

/**
 * Resets state for the next round, immediately swapping the setting/guessing teams
 * and carrying over the cumulative session scores.
 */
export function createNextHangmanRound(
  previousState: HangmanState,
  outcome: RoundScoreResult
): HangmanState {
  return {
    teamAName: previousState.teamAName,
    teamBName: previousState.teamBName,
    settingTeam: previousState.settingTeam === 'teamA' ? 'teamB' : 'teamA', // Automatic role swap!
    secretWord: '',
    clues: [],
    guessedLetters: new Set<string>(),
    cluesViewed: false,
    scoreTeamA: outcome.updatedScoreTeamA,
    scoreTeamB: outcome.updatedScoreTeamB,
  };
}

