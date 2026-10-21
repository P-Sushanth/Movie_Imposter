import 'movie.dart';

enum RoleKind {
  movie,
  imposter,
}

abstract class PlayerRole {
  RoleKind get kind;
}

class NormalPlayerRole extends PlayerRole {
  final String movieTitle;
  final Industry industry;

  NormalPlayerRole({
    required this.movieTitle,
    required this.industry,
  });

  @override
  RoleKind get kind => RoleKind.movie;
}

class ImposterRole extends PlayerRole {
  final String? clueText;
  final String? clueLabel;
  final String? revealedMovieTitle;

  ImposterRole({
    this.clueText,
    this.clueLabel,
    this.revealedMovieTitle,
  });

  @override
  RoleKind get kind => RoleKind.imposter;
}

class PlayerAssignment {
  final String playerId;
  final String playerName;
  final PlayerRole role;

  PlayerAssignment({
    required this.playerId,
    required this.playerName,
    required this.role,
  });
}
