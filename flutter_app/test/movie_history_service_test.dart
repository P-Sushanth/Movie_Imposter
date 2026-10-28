import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_imposter/services/movie_history_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MovieHistoryService', () {
    test('loadUsedMovieIds returns empty list initially', () async {
      final list = await MovieHistoryService.loadUsedMovieIds();
      expect(list, isEmpty);
    });

    test('records used movie IDs and keeps order', () async {
      await MovieHistoryService.recordUsedMovieId('m1');
      await MovieHistoryService.recordUsedMovieId('m2');
      await MovieHistoryService.recordUsedMovieId('m3');

      final list = await MovieHistoryService.loadUsedMovieIds();
      expect(list, equals(['m1', 'm2', 'm3']));
    });

    test('moves duplicate to end when played again', () async {
      await MovieHistoryService.recordUsedMovieId('m1');
      await MovieHistoryService.recordUsedMovieId('m2');
      await MovieHistoryService.recordUsedMovieId('m1');

      final list = await MovieHistoryService.loadUsedMovieIds();
      expect(list, equals(['m2', 'm1']));
    });

    test('respects max cache window', () async {
      final ids = List.generate(
        MovieHistoryService.kMaxCachedUsedMovies + 20,
        (i) => 'movie_$i',
      );
      await MovieHistoryService.saveUsedMovieIds(ids);

      final loaded = await MovieHistoryService.loadUsedMovieIds();
      expect(loaded.length, equals(MovieHistoryService.kMaxCachedUsedMovies));
      expect(loaded.first, equals('movie_20'));
      expect(loaded.last, equals('movie_${MovieHistoryService.kMaxCachedUsedMovies + 19}'));
    });

    test('clears used movies cache', () async {
      await MovieHistoryService.recordUsedMovieId('m1');
      await MovieHistoryService.clearUsedMovies();
      final list = await MovieHistoryService.loadUsedMovieIds();
      expect(list, isEmpty);
    });
  });
}

