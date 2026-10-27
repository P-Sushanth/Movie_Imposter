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
  final List<Industry> selectedIndustries;
  final List<String> players;
  final List<String> imposters;
  final int numImposters;
  final bool imposterClueEnabled;
  final bool revealNameToImposter;
  final int discussionTimerMinutes;
  final String? imposterClueKey;
  final List<PlayerAssignment> assignments;
  final String startingPlayer;
  final List<String> discussionOrder;
  int currentCardIndex;
  RoundPhase phase;

  RoundState({
    required this.movieId,
    required this.movieTitle,
    required this.industry,
    this.selectedIndustries = const [],
    required this.players,
    required this.imposters,
    required this.numImposters,
    required this.imposterClueEnabled,
    this.revealNameToImposter = false,
    this.discussionTimerMinutes = 0,
    this.imposterClueKey,
    required this.assignments,
    required this.startingPlayer,
    required this.discussionOrder,
    this.currentCardIndex = 0,
    this.phase = RoundPhase.dealing,
  });

  RoundState copyWith({
    String? movieId,
    String? movieTitle,
    Industry? industry,
    List<Industry>? selectedIndustries,
    List<String>? players,
    List<String>? imposters,
    int? numImposters,
    bool? imposterClueEnabled,
    bool? revealNameToImposter,
    int? discussionTimerMinutes,
    String? imposterClueKey,
    List<PlayerAssignment>? assignments,
    String? startingPlayer,
    List<String>? discussionOrder,
    int? currentCardIndex,
    RoundPhase? phase,
  }) {
    return RoundState(
      movieId: movieId ?? this.movieId,
      movieTitle: movieTitle ?? this.movieTitle,
      industry: industry ?? this.industry,
      selectedIndustries: selectedIndustries ?? this.selectedIndustries,
      players: players ?? this.players,
      imposters: imposters ?? this.imposters,
      numImposters: numImposters ?? this.numImposters,
      imposterClueEnabled: imposterClueEnabled ?? this.imposterClueEnabled,
      revealNameToImposter: revealNameToImposter ?? this.revealNameToImposter,
      discussionTimerMinutes: discussionTimerMinutes ?? this.discussionTimerMinutes,
      imposterClueKey: imposterClueKey ?? this.imposterClueKey,
      assignments: assignments ?? this.assignments,
      startingPlayer: startingPlayer ?? this.startingPlayer,
      discussionOrder: discussionOrder ?? this.discussionOrder,
      currentCardIndex: currentCardIndex ?? this.currentCardIndex,
      phase: phase ?? this.phase,
    );
  }
}
