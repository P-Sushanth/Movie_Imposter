class ValidationResult {
  final bool isValid;
  final String? error;

  const ValidationResult({required this.isValid, this.error});
}

/// Resolves player names: if a player name is empty or blank,
/// defaults to "Player 1", "Player 2", etc.
List<String> resolvePlayerNames(List<String>? names) {
  if (names == null) return [];
  return names.asMap().entries.map((entry) {
    final index = entry.key;
    final name = entry.value;
    final trimmed = name.trim();
    return trimmed.isNotEmpty ? trimmed : 'Player ${index + 1}';
  }).toList();
}

/// Validates a list of player names.
/// - Minimum: 3 players
/// - Maximum: 10 players
/// - Automatically defaults blank names to "Player X"
/// - Checks for duplicates ignoring case
ValidationResult validatePlayers(List<String>? names) {
  if (names == null || names.length < 3) {
    return const ValidationResult(
      isValid: false,
      error: 'You need at least 3 players to start a round.',
    );
  }

  if (names.length > 10) {
    return const ValidationResult(
      isValid: false,
      error: 'Maximum 10 players supported.',
    );
  }

  final resolved = resolvePlayerNames(names);
  final seen = <String>{};

  for (final name in resolved) {
    final lower = name.toLowerCase();
    if (seen.contains(lower)) {
      return ValidationResult(
        isValid: false,
        error: 'Duplicate name "$name". Every player must have a unique name.',
      );
    }
    seen.add(lower);
  }

  return const ValidationResult(isValid: true);
}
