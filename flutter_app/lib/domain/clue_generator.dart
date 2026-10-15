import 'dart:math';
import '../models/movie.dart';

/// Checks if a candidate clue text accidentally contains the movie title.
bool clueContainsTitle(String title, String value) {
  if (title.isEmpty || value.isEmpty) return false;
  final cleanTitle = title.trim().toLowerCase();
  final cleanVal = value.trim().toLowerCase();

  if (cleanVal.length >= 3 && cleanTitle.length >= 3) {
    if (cleanVal.contains(cleanTitle) || cleanTitle.contains(cleanVal)) {
      return true;
    }
  }
  return false;
}

/// Formats individual movie features into punchy, keyword-based clues.
/// Uses concise labels and values instead of full sentences.
List<ClueItem> getCluesForMovie(Movie movie) {
  final clues = <ClueItem>[];

  // 1. Decade
  if (movie.decade.isNotEmpty && !clueContainsTitle(movie.title, movie.decade)) {
    clues.add(ClueItem(
      key: 'decade',
      label: 'Decade',
      value: movie.decade,
      displayText: 'Decade: ${movie.decade}',
    ));
  }

  // 2. Hero
  if (movie.hero.isNotEmpty && !clueContainsTitle(movie.title, movie.hero)) {
    clues.add(ClueItem(
      key: 'hero',
      label: 'Hero',
      value: movie.hero,
      displayText: 'Hero: ${movie.hero}',
    ));
  }

  // 3. Director
  if (movie.director.isNotEmpty && !clueContainsTitle(movie.title, movie.director)) {
    clues.add(ClueItem(
      key: 'director',
      label: 'Director',
      value: movie.director,
      displayText: 'Director: ${movie.director}',
    ));
  }

  // 4. Genre
  if (movie.genre.isNotEmpty && !clueContainsTitle(movie.title, movie.genre)) {
    clues.add(ClueItem(
      key: 'genre',
      label: 'Genre',
      value: movie.genre,
      displayText: 'Genre: ${movie.genre}',
    ));
  }

  // 5. Is Adult
  final adultValue = movie.isAdult ? 'Adult (A)' : 'Universal (U/UA)';
  clues.add(ClueItem(
    key: 'is_adult',
    label: 'Rating',
    value: adultValue,
    displayText: 'Rating: $adultValue',
  ));

  // 6. Is Remake
  final remakeValue = movie.isRemake ? 'Remake' : 'Original';
  clues.add(ClueItem(
    key: 'is_remake',
    label: 'Story Type',
    value: remakeValue,
    displayText: 'Story Type: $remakeValue',
  ));

  return clues;
}

/// Picks one clue for the imposter, avoiding title leaks and allowing an injectable random function.
ClueItem? generateImposterClue(
  Movie movie, {
  double Function()? random,
}) {
  final validClues = getCluesForMovie(movie);
  if (validClues.isEmpty) return null;

  final rng = random ?? () => Random().nextDouble();
  final index = (rng() * validClues.length).floor().clamp(0, validClues.length - 1);
  return validClues[index];
}
