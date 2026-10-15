export interface ValidationResult {
  isValid: boolean;
  error?: string;
}

/**
 * Resolves player names: if a player name is empty or blank,
 * defaults to "Player 1", "Player 2", etc.
 */
export function resolvePlayerNames(names: string[]): string[] {
  if (!names) return [];
  return names.map((name, index) => {
    const trimmed = (name || "").trim();
    return trimmed.length > 0 ? trimmed : `Player ${index + 1}`;
  });
}

/**
 * Validates a list of player names.
 * - Minimum: 3 players
 * - Maximum: 10 players
 * - Automatically defaults blank names to "Player X"
 * - Checks for duplicates ignoring case
 */
export function validatePlayers(names: string[]): ValidationResult {
  if (!names || names.length < 3) {
    return {
      isValid: false,
      error: "You need at least 3 players to start a round.",
    };
  }

  if (names.length > 10) {
    return {
      isValid: false,
      error: "Maximum 10 players supported.",
    };
  }

  const resolved = resolvePlayerNames(names);
  const seen = new Set<string>();

  for (let i = 0; i < resolved.length; i++) {
    const name = resolved[i];
    const lower = name.toLowerCase();
    if (seen.has(lower)) {
      return {
        isValid: false,
        error: `Duplicate name "${name}". Every player must have a unique name.`,
      };
    }
    seen.add(lower);
  }

  return { isValid: true };
}
