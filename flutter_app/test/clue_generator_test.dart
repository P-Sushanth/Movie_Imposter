import 'package:flutter_test/flutter_test.dart';
import 'package:movie_imposter/domain/clue_generator.dart';
import 'package:movie_imposter/models/movie.dart';

void main() {
  group('Clue Generation', () {
    const sampleMovie = Movie(
      id: 'test-001',
      title: 'Pokiri',
      industry: Industry.tollywood,
      hero: 'Mahesh Babu',
      director: 'Puri Jagannadh',
      genre: 'Action Thriller',
    );

    test('produces non-empty clues for all valid features', () {
      final clues = getCluesForMovie(sampleMovie);
      expect(clues.isNotEmpty, isTrue);
      for (final clue in clues) {
        expect(clue.displayText.isNotEmpty, isTrue);
      }
    });

    test('does not leak the movie title in any clue', () {
      const movieWithTitleInHero = Movie(
        id: 'test-002',
        title: 'Hero',
        industry: Industry.bollywood,
        hero: 'Hero',
        director: 'Subhash Ghai',
        genre: 'Action Romance',
      );

      final clues = getCluesForMovie(movieWithTitleInHero);
      final heroClues = clues.where((c) => c.key == 'hero');
      expect(heroClues.isEmpty, isTrue); // Safely omitted to prevent title leakage!
    });

    test('generates a random clue with injected RNG', () {
      final clueFirst = generateImposterClue(sampleMovie, random: () => 0.0);
      final clueLast = generateImposterClue(sampleMovie, random: () => 0.99);

      expect(clueFirst, isNotNull);
      expect(clueLast, isNotNull);
      expect(clueFirst?.displayText.isNotEmpty, isTrue);
    });

    test('produces all 4 clues (hero, director, genre, hint) for movies with hint', () {
      const movieWithHint = Movie(
        id: 'tollywood-001',
        title: 'Badri',
        industry: Industry.tollywood,
        hero: 'Pawan Kalyan',
        director: 'Puri Jagannadh',
        genre: 'Action Romance',
        hint: 'Bay Of Bengal',
      );

      final clues = getCluesForMovie(movieWithHint);
      final keys = clues.map((c) => c.key).toList();
      expect(keys, equals(['hero', 'director', 'genre', 'hint']));
      expect(clues.firstWhere((c) => c.key == 'hint').displayText, 'Hint: Bay Of Bengal');
      expect(clues.any((c) => c.key == 'release_year'), isFalse);
      expect(clues.any((c) => c.key == 'decade'), isFalse);
    });

    test('generates show-specific clues for Industry.shows', () {
      const sampleShow = Movie(
        id: 'show-001',
        title: 'Breaking Bad',
        industry: Industry.shows,
        genre: 'Crime Drama',
        productionHouse: 'AMC',
        seasonsCount: 5,
        startYear: 2008,
        endYear: '2013',
        adaptationOrOriginal: 'Original',
        releaseMedium: 'TV Release',
      );

      final clues = getCluesForMovie(sampleShow);
      final keys = clues.map((c) => c.key).toSet();

      // Must have the exact 6 requested show clue types
      expect(keys.contains('production_house'), isTrue);
      expect(keys.contains('seasons_count'), isTrue);
      expect(keys.contains('start_year'), isTrue);
      expect(keys.contains('end_year'), isTrue);
      expect(keys.contains('adaptation_or_original'), isTrue);
      expect(keys.contains('release_medium'), isTrue);

      // Must not contain premise_line or standard movie clues
      expect(keys.contains('premise_line'), isFalse);
      expect(keys.contains('hero'), isFalse);
      expect(keys.contains('director'), isFalse);
      expect(keys.contains('is_adult'), isFalse);
      expect(keys.contains('is_remake'), isFalse);
      expect(keys.contains('decade'), isFalse);
      expect(keys.contains('release_year'), isFalse);

      final prodClue = clues.firstWhere((c) => c.key == 'production_house');
      expect(prodClue.displayText, 'Production House: AMC');

      final seasonClue = clues.firstWhere((c) => c.key == 'seasons_count');
      expect(seasonClue.displayText, 'Number of Seasons: 5 Seasons');

      final startClue = clues.firstWhere((c) => c.key == 'start_year');
      expect(startClue.displayText, 'Start Year: 2008');

      final endClue = clues.firstWhere((c) => c.key == 'end_year');
      expect(endClue.displayText, 'End Year: 2013');

      final typeClue = clues.firstWhere((c) => c.key == 'adaptation_or_original');
      expect(typeClue.displayText, 'Story: Original');

      final mediumClue = clues.firstWhere((c) => c.key == 'release_medium');
      expect(mediumClue.displayText, 'Release: TV Release');
    });

    test('prevents show title leak in production house', () {
      const showWithTitleInPlatform = Movie(
        id: 'show-002',
        title: 'Netflix Showdown',
        industry: Industry.shows,
        genre: 'Reality',
        productionHouse: 'Netflix',
        seasonsCount: 1,
        startYear: 2020,
        endYear: '2020',
        adaptationOrOriginal: 'Original',
        releaseMedium: 'OTT Release',
      );

      final clues = getCluesForMovie(showWithTitleInPlatform);
      final prodClues = clues.where((c) => c.key == 'production_house');
      expect(prodClues.isEmpty, isTrue); // Safely omitted because it leaked the title!
    });

    test('generates show-specific clues for Industry.kdrama', () {
      const sampleKdrama = Movie(
        id: 'kdrama-001',
        title: 'Squid Game',
        industry: Industry.kdrama,
        genre: 'Survival Dystopian Thriller',
        productionHouse: 'Netflix',
        seasonsCount: 2,
        startYear: 2021,
        endYear: 'Ongoing',
        adaptationOrOriginal: 'Original',
        releaseMedium: 'OTT Release',
      );

      final clues = getCluesForMovie(sampleKdrama);
      final keys = clues.map((c) => c.key).toSet();

      expect(keys.contains('production_house'), isTrue);
      expect(keys.contains('seasons_count'), isTrue);
      expect(keys.contains('start_year'), isTrue);
      expect(keys.contains('end_year'), isTrue);
      expect(keys.contains('adaptation_or_original'), isTrue);
      expect(keys.contains('release_medium'), isTrue);
      expect(keys.contains('release_year'), isFalse);
      expect(keys.contains('decade'), isFalse);
    });

    test('does not include releaseYear or decade regardless of player count', () {
      const movie = Movie(
        id: 'tollywood-001',
        title: 'Badri',
        industry: Industry.tollywood,
        hero: 'Pawan Kalyan',
        director: 'Puri Jagannadh',
        genre: 'Action Romance',
        hint: 'Bay Of Bengal',
      );

      for (final pCount in [3, 4, 5, 8]) {
        final clues = getCluesForMovie(movie, playerCount: pCount);
        final keys = clues.map((c) => c.key).toSet();
        expect(keys.contains('release_year'), isFalse);
        expect(keys.contains('decade'), isFalse);
        expect(keys.contains('hero'), isTrue);
        expect(keys.contains('director'), isTrue);
        expect(keys.contains('genre'), isTrue);
        expect(keys.contains('hint'), isTrue);
      }
    });

    test('generateImposterClue avoids repeating previousClueKey when other clues exist', () {
      const movie = Movie(
        id: 'tollywood-001',
        title: 'Badri',
        industry: Industry.tollywood,
        hero: 'Pawan Kalyan',
        director: 'Puri Jagannadh',
        genre: 'Action Romance',
        hint: 'Bay Of Bengal',
      );

      // If previous clue was 'genre', generated clue must NOT be 'genre'
      for (int i = 0; i < 20; i++) {
        final clue = generateImposterClue(
          movie,
          playerCount: 5,
          previousClueKey: 'genre',
        );
        expect(clue?.key, isNot(equals('genre')));
      }
    });

    test('generates cartoon clues (channel, countryOfOrigin, hint) for Industry.cartoons', () {
      const cartoon = Movie(
        id: 'cartoons-001',
        title: 'Doraemon',
        industry: Industry.cartoons,
        channel: 'Hungama TV',
        countryOfOrigin: 'Japan',
        hint: 'Pipes',
      );

      final clues = getCluesForMovie(cartoon);
      final keys = clues.map((c) => c.key).toList();
      expect(keys, equals(['channel', 'country_of_origin', 'hint']));
      expect(clues.firstWhere((c) => c.key == 'channel').displayText, 'Channel: Hungama TV');
      expect(clues.firstWhere((c) => c.key == 'country_of_origin').displayText, 'Country: Japan');
      expect(clues.firstWhere((c) => c.key == 'hint').displayText, 'Hint: Pipes');
      expect(clues.any((c) => c.key == 'release_year'), isFalse);
      expect(clues.any((c) => c.key == 'decade'), isFalse);
    });
  });
}
