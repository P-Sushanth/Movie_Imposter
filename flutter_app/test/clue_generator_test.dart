import 'package:flutter_test/flutter_test.dart';
import 'package:movie_imposter/domain/clue_generator.dart';
import 'package:movie_imposter/models/movie.dart';

void main() {
  group('Clue Generation', () {
    const sampleMovie = Movie(
      id: 'test-001',
      title: 'Pokiri',
      industry: Industry.tollywood,
      releaseYear: 2006,
      decade: '2000s',
      hero: 'Mahesh Babu',
      director: 'Puri Jagannadh',
      genre: 'Action Thriller',
      isAdult: false,
      isRemake: false,
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
        releaseYear: 1983,
        decade: '1980s',
        hero: 'Hero',
        director: 'Subhash Ghai',
        genre: 'Action Romance',
        isAdult: false,
        isRemake: false,
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
  });
}
