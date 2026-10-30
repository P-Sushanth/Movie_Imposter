import {
  getMaskedCharacters,
  getWrongGuesses,
  getStrikeCount,
  isWordGuessed,
  isHangmanExpired,
  isRoundOver,
  calculateRoundOutcome,
  createNextHangmanRound,
  HangmanState,
} from '../domain/hangman';

describe('Hangman Domain Engine', () => {
  describe('Word Masking & Punctuation', () => {
    it('masks unguessed alphanumeric characters as underscores', () => {
      const masked = getMaskedCharacters('DEVARA', new Set(['D', 'A']));
      expect(masked.join('')).toBe('D__A_A');
    });

    it('automatically reveals spaces, dashes, colons, and exclamation marks', () => {
      const masked = getMaskedCharacters('RRR: Part 1 - Fire!', new Set(['R']));
      expect(masked.join('')).toBe('RRR: __R_ _ - __R_!');
    });

    it('handles numeric digits properly', () => {
      const masked = getMaskedCharacters('KGF 2', new Set(['2']));
      expect(masked.join('')).toBe('___ 2');
    });
  });

  describe('Strike Counting', () => {
    it('identifies wrong guesses correctly', () => {
      const wrong = getWrongGuesses('BAAHUBALI', new Set(['B', 'A', 'Z', 'X']));
      expect(wrong.sort()).toEqual(['X', 'Z']);
    });

    it('caps strikes at MAX_STRIKES (7)', () => {
      const wrongGuesses = new Set(['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P']);
      const count = getStrikeCount('JAVA', wrongGuesses);
      expect(count).toBe(7);
    });
  });

  describe('Win and Loss Conditions', () => {
    it('detects when the word has been completely guessed', () => {
      expect(isWordGuessed('PUSHPA', new Set(['P', 'U', 'S', 'H', 'A']))).toBe(true);
      expect(isWordGuessed('PUSHPA', new Set(['P', 'U', 'S', 'H']))).toBe(false);
    });

    it('detects when 7 strikes are reached', () => {
      const sevenWrong = new Set(['B', 'C', 'D', 'F', 'G', 'H', 'J']);
      expect(isHangmanExpired('AAA', sevenWrong)).toBe(true);
      expect(isRoundOver('AAA', sevenWrong)).toBe(true);
    });
  });

  describe('Scoring Rules & 2-Point Bonus', () => {
    const baseState: HangmanState = {
      teamAName: 'Team Popcorn',
      teamBName: 'Team Cinema',
      settingTeam: 'teamA',
      secretWord: 'INTERSTELLAR',
      clues: ['Sci-fi film', 'Nolan', 'Black hole'],
      guessedLetters: new Set(['I', 'N', 'T', 'E', 'R', 'S', 'L', 'A']),
      cluesViewed: false,
      scoreTeamA: 2,
      scoreTeamB: 1,
    };

    it('awards +2 Points to guessing team if solved without looking at clues', () => {
      const outcome = calculateRoundOutcome({
        ...baseState,
        cluesViewed: false,
      });

      expect(outcome.winner).toBe('teamB');
      expect(outcome.pointsAwarded).toBe(2);
      expect(outcome.reason).toBe('GUESSED_WITHOUT_CLUES');
      expect(outcome.updatedScoreTeamA).toBe(2);
      expect(outcome.updatedScoreTeamB).toBe(3); // 1 + 2
    });

    it('awards +1 Point to guessing team if clues were opened', () => {
      const outcome = calculateRoundOutcome({
        ...baseState,
        cluesViewed: true,
      });

      expect(outcome.winner).toBe('teamB');
      expect(outcome.pointsAwarded).toBe(1);
      expect(outcome.reason).toBe('GUESSED_WITH_CLUES');
      expect(outcome.updatedScoreTeamA).toBe(2);
      expect(outcome.updatedScoreTeamB).toBe(2); // 1 + 1
    });

    it('awards +1 Point to setting team when 7 strikes expire', () => {
      const expiredState: HangmanState = {
        ...baseState,
        guessedLetters: new Set(['Q', 'W', 'Y', 'U', 'O', 'P', 'Z']), // 7 wrong
      };

      const outcome = calculateRoundOutcome(expiredState);
      expect(outcome.winner).toBe('teamA'); // Setting team
      expect(outcome.pointsAwarded).toBe(1);
      expect(outcome.reason).toBe('STRIKES_EXPIRED');
      expect(outcome.updatedScoreTeamA).toBe(3); // 2 + 1
      expect(outcome.updatedScoreTeamB).toBe(1);
    });
  });

  describe('Role Swapping Across Rounds', () => {
    it('swaps setting and guessing teams for next round while preserving cumulative scores', () => {
      const state: HangmanState = {
        teamAName: 'Team Popcorn',
        teamBName: 'Team Cinema',
        settingTeam: 'teamA',
        secretWord: 'DEVARA',
        clues: ['NTR', 'Koratala'],
        guessedLetters: new Set(['D', 'E', 'V', 'A', 'R']),
        cluesViewed: false,
        scoreTeamA: 2,
        scoreTeamB: 1,
      };

      const outcome = calculateRoundOutcome(state);
      const nextRound = createNextHangmanRound(state, outcome);

      expect(nextRound.settingTeam).toBe('teamB'); // Swapped!
      expect(nextRound.scoreTeamA).toBe(2);
      expect(nextRound.scoreTeamB).toBe(3); // 1 + 2
      expect(nextRound.secretWord).toBe('');
      expect(nextRound.clues).toEqual([]);
      expect(nextRound.guessedLetters.size).toBe(0);
      expect(nextRound.cluesViewed).toBe(false);
    });
  });
});
