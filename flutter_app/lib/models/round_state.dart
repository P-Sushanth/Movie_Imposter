import 'movie.dart';
import 'role.dart';

enum RoundPhase {
  dealing,
  discussion,
}

class RoundState {
  final String movieId;
  final String movieTitle;
  final Industry industry;
  final List<String> players;
  final List<String> imposters;
  final int numImposters;
  final bool imposterClueEnabled;
  final List<PlayerAssignment> assignments;
  int currentCardIndex;
  RoundPhase phase;

  RoundState({
    required this.movieId,
    required this.movieTitle,
    required this.industry,
    required this.players,
    required this.imposters,
    required this.numImposters,
    required this.imposterClueEnabled,
    required this.assignments,
    this.currentCardIndex = 0,
    this.phase = RoundPhase.dealing,
  });

  RoundState copyWith({
    String? movieId,
    String? movieTitle,
    Industry? industry,
    List<String>? players,
    List<String>? imposters,
    int? numImposters,
    bool? imposterClueEnabled,
    List<PlayerAssignment>? assignments,
    int? currentCardIndex,
    RoundPhase? phase,
  }) {
    return RoundState(
      movieId: movieId ?? this.movieId,
      movieTitle: movieTitle ?? this.movieTitle,
      industry: industry ?? this.industry,
      players: players ?? this.players,
      imposters: imposters ?? this.imposters,
      numImposters: numImposters ?? this.numImposters,
      imposterClueEnabled: imposterClueEnabled ?? this.imposterClueEnabled,
      assignments: assignments ?? this.assignments,
      currentCardIndex: currentCardIndex ?? this.currentCardIndex,
      phase: phase ?? this.phase,
    );
  }
}
