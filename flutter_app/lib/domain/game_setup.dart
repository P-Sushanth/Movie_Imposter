import 'dart:math';
import '../models/movie.dart';
import '../models/role.dart';
import '../models/round_state.dart';
import 'clue_generator.dart';
import 'validation.dart';

class CreateRoundParams {
  final List<String> players;
  final List<Industry> selectedIndustries;
  final List<Movie> moviePool;
  final int numImposters;
  final bool imposterClueEnabled;
  final String? previousMovieId;
  final double Function()? random;

  CreateRoundParams({
    required this.players,
    required this.selectedIndustries,
    required this.moviePool,
    this.numImposters = 1,
    this.imposterClueEnabled = true,
    this.previousMovieId,
    this.random,
  });
}

RoundState createRound(CreateRoundParams params) {
  final rng = params.random ?? () => Random().nextDouble();

  // 1. Resolve default player names (e.g. blank -> "Player 1")
  final resolvedPlayers = resolvePlayerNames(params.players);

  // 2. Validate players
  final playerValidation = validatePlayers(resolvedPlayers);
  if (!playerValidation.isValid) {
    throw ArgumentError(playerValidation.error ?? 'Invalid player list');
  }

  // 3. Validate imposters count
  final maxAllowed = resolvedPlayers.length ~/ 2;
  final safeNumImposters = params.numImposters.clamp(1, maxAllowed > 0 ? maxAllowed : 1);

  // 4. Filter movies by selected industries
  final industrySet = params.selectedIndustries.toSet();
  var eligibleMovies = params.moviePool.where((m) => industrySet.contains(m.industry)).toList();

  if (eligibleMovies.isEmpty) {
    throw StateError('No eligible movies found for the selected industries.');
  }

  // 5. Avoid repeating previous movie if alternatives exist
  if (params.previousMovieId != null && eligibleMovies.length > 1) {
    final withoutPrevious = eligibleMovies.where((m) => m.id != params.previousMovieId).toList();
    if (withoutPrevious.isNotEmpty) {
      eligibleMovies = withoutPrevious;
    }
  }

  // 6. Select movie and (if clue enabled) generate clue
  Movie? selectedMovie;
  ClueItem? imposterClue;

  final candidatePool = List<Movie>.from(eligibleMovies);

  while (candidatePool.isNotEmpty && selectedMovie == null) {
    final movieIndex = (rng() * candidatePool.length).floor().clamp(0, candidatePool.length - 1);
    final candidate = candidatePool.removeAt(movieIndex);

    if (params.imposterClueEnabled) {
      final clue = generateImposterClue(candidate, random: rng);
      if (clue != null) {
        selectedMovie = candidate;
        imposterClue = clue;
        break;
      }
    } else {
      selectedMovie = candidate;
      break;
    }
  }

  if (selectedMovie == null) {
    throw StateError('Failed to find an eligible movie.');
  }

  // 7. Pick distinct imposter indices uniformly at random
  final allIndices = List<int>.generate(resolvedPlayers.length, (i) => i);
  final imposterIndices = <int>{};

  while (imposterIndices.length < safeNumImposters && allIndices.isNotEmpty) {
    final pickIdx = (rng() * allIndices.length).floor().clamp(0, allIndices.length - 1);
    final chosen = allIndices.removeAt(pickIdx);
    imposterIndices.add(chosen);
  }

  // 8. Assign roles
  final imposterNames = <String>[];
  final assignments = <PlayerAssignment>[];

  for (int i = 0; i < resolvedPlayers.length; i++) {
    final name = resolvedPlayers[i];
    final playerId = 'player-${i + 1}';

    if (imposterIndices.contains(i)) {
      imposterNames.add(name);
      assignments.add(
        PlayerAssignment(
          playerId: playerId,
          playerName: name,
          role: ImposterRole(
            clueText: params.imposterClueEnabled && imposterClue != null ? imposterClue.displayText : null,
            clueLabel: params.imposterClueEnabled && imposterClue != null ? imposterClue.label : null,
          ),
        ),
      );
    } else {
      assignments.add(
        PlayerAssignment(
          playerId: playerId,
          playerName: name,
          role: NormalPlayerRole(
            movieTitle: selectedMovie.title,
            industry: selectedMovie.industry,
          ),
        ),
      );
    }
  }

  return RoundState(
    movieId: selectedMovie.id,
    movieTitle: selectedMovie.title,
    industry: selectedMovie.industry,
    players: resolvedPlayers,
    imposters: imposterNames,
    numImposters: safeNumImposters,
    imposterClueEnabled: params.imposterClueEnabled,
    assignments: assignments,
    currentCardIndex: 0,
    phase: RoundPhase.dealing,
  );
}
