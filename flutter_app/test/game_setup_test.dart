import 'package:flutter_test/flutter_test.dart';
import 'package:movie_imposter/data/movies_data.dart';
import 'package:movie_imposter/domain/game_setup.dart';
import 'package:movie_imposter/models/movie.dart';
import 'package:movie_imposter/models/role.dart';

void main() {
  group('Game Setup & Role Assignment', () {
    final players = ['Prabhas', 'Rajamouli', 'Anushka', 'Rana', 'Tamannaah'];

    test('assigns configured number of imposters', () {
      final roundOne = createRound(
        CreateRoundParams(
          players: players,
          selectedIndustries: [Industry.tollywood],
          moviePool: kAllMovies,
          numImposters: 1,
        ),
      );
      expect(roundOne.imposters.length, equals(1));

      final roundTwo = createRound(
        CreateRoundParams(
          players: players,
          selectedIndustries: [Industry.tollywood],
          moviePool: kAllMovies,
          numImposters: 2,
        ),
      );
      expect(roundTwo.imposters.length, equals(2));
      expect(roundTwo.assignments.where((a) => a.role is ImposterRole).length, equals(2));
    });

    test('handles imposter clues disabled properly', () {
      final roundNoClues = createRound(
        CreateRoundParams(
          players: players,
          selectedIndustries: [Industry.tollywood],
          moviePool: kAllMovies,
          imposterClueEnabled: false,
        ),
      );
      final imposter = roundNoClues.assignments.firstWhere((a) => a.role is ImposterRole);
      expect((imposter.role as ImposterRole).clueText, isNull);
    });

    test('assigns the exact same movie to all non-imposters', () {
      final round = createRound(
        CreateRoundParams(
          players: players,
          selectedIndustries: [Industry.tollywood],
          moviePool: kAllMovies,
        ),
      );

      final movieRoles = round.assignments
          .where((a) => a.role is NormalPlayerRole)
          .map((a) => (a.role as NormalPlayerRole).movieTitle)
          .toList();

      expect(movieRoles.length, equals(players.length - 1));
      final uniqueTitles = movieRoles.toSet();
      expect(uniqueTitles.length, equals(1));
      expect(uniqueTitles.contains(round.movieTitle), isTrue);
    });

    test('filters movies by selected industries correctly', () {
      final tollywoodOnly = getMoviesByIndustries([Industry.tollywood]);
      expect(tollywoodOnly.isNotEmpty, isTrue);
      expect(tollywoodOnly.every((m) => m.industry == Industry.tollywood), isTrue);
    });

    test('supports starting consecutive rounds without immediate movie duplication when options exist', () {
      final round1 = createRound(
        CreateRoundParams(
          players: players,
          selectedIndustries: [Industry.tollywood],
          moviePool: kAllMovies,
          random: () => 0.1,
        ),
      );

      final round2 = createRound(
        CreateRoundParams(
          players: players,
          selectedIndustries: [Industry.tollywood],
          moviePool: kAllMovies,
          previousMovieId: round1.movieId,
          random: () => 0.1,
        ),
      );

      expect(round2.movieId, isNot(equals(round1.movieId)));
    });

    test('excludes movies played in the current session', () {
      final used = <String>{};
      final round1 = createRound(
        CreateRoundParams(
          players: players,
          selectedIndustries: [Industry.tollywood],
          moviePool: kAllMovies,
          usedMovieIds: used,
        ),
      );
      used.add(round1.movieId);

      final round2 = createRound(
        CreateRoundParams(
          players: players,
          selectedIndustries: [Industry.tollywood],
          moviePool: kAllMovies,
          usedMovieIds: used,
        ),
      );
      used.add(round2.movieId);

      expect(round2.movieId, isNot(equals(round1.movieId)));
      expect(used.contains(round1.movieId), isTrue);
      expect(used.contains(round2.movieId), isTrue);
    });

    test('recycles session movies gracefully when all eligible movies are used', () {
      final miniPool = kAllMovies.where((m) => m.industry == Industry.tollywood).take(2).toList();
      final used = <String>{miniPool[0].id, miniPool[1].id};

      final round = createRound(
        CreateRoundParams(
          players: players,
          selectedIndustries: [Industry.tollywood],
          moviePool: miniPool,
          usedMovieIds: used,
        ),
      );

      expect(miniPool.any((m) => m.id == round.movieId), isTrue);
    });

    test('assigns a valid starting player and discussion order', () {
      final round = createRound(
        CreateRoundParams(
          players: players,
          selectedIndustries: [Industry.tollywood],
          moviePool: kAllMovies,
        ),
      );

      expect(players.contains(round.startingPlayer), isTrue);
      expect(round.discussionOrder.length, equals(players.length));
      expect(round.discussionOrder.first, equals(round.startingPlayer));
      expect(round.discussionOrder.toSet(), equals(players.toSet()));
    });
  });
}
