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

/// Formats show features into show-specific clues:
/// Production House, Number of Seasons, Start year, End year,
/// Adaptation or Original, and TV release or OTT release.
List<ClueItem> getCluesForShow(Movie show, {int? playerCount}) {
  final clues = <ClueItem>[];
  final canIncludeYear = playerCount == null || playerCount > 4;

  // 1. Production House (Platform)
  if (show.productionHouse != null &&
      show.productionHouse!.isNotEmpty &&
      !clueContainsTitle(show.title, show.productionHouse!)) {
    clues.add(ClueItem(
      key: 'production_house',
      label: 'Production House',
      value: show.productionHouse!,
      displayText: 'Production House: ${show.productionHouse}',
    ));
  }

  // 2. Number of Seasons
  if (show.seasonsCount != null) {
    final sText = '${show.seasonsCount} ${show.seasonsCount == 1 ? 'Season' : 'Seasons'}';
    clues.add(ClueItem(
      key: 'seasons_count',
      label: 'Number of Seasons',
      value: sText,
      displayText: 'Number of Seasons: $sText',
    ));
  }

  // 3. Start Year (only included when player count is > 4)
  if (canIncludeYear) {
    final startYr = show.startYear ?? show.releaseYear;
    clues.add(ClueItem(
      key: 'start_year',
      label: 'Start Year',
      value: '$startYr',
      displayText: 'Start Year: $startYr',
    ));
  }

  // 4. End Year (only included when player count is > 4)
  if (canIncludeYear && show.endYear != null && show.endYear!.isNotEmpty) {
    clues.add(ClueItem(
      key: 'end_year',
      label: 'End Year',
      value: show.endYear!,
      displayText: 'End Year: ${show.endYear}',
    ));
  }

  // 5. Adaptation or Original
  if (show.adaptationOrOriginal != null && show.adaptationOrOriginal!.isNotEmpty) {
    clues.add(ClueItem(
      key: 'adaptation_or_original',
      label: 'Adaptation / Original',
      value: show.adaptationOrOriginal!,
      displayText: 'Story: ${show.adaptationOrOriginal}',
    ));
  }

  // 6. TV release or OTT release
  if (show.releaseMedium != null && show.releaseMedium!.isNotEmpty) {
    clues.add(ClueItem(
      key: 'release_medium',
      label: 'Release Type',
      value: show.releaseMedium!,
      displayText: 'Release: ${show.releaseMedium}',
    ));
  }

  return clues;
}

/// Formats cartoon features into cartoon-specific clues:
/// Release Year, Decade, Channel, Country of Origin, and Hint.
List<ClueItem> getCluesForCartoon(Movie cartoon, {int? playerCount}) {
  final clues = <ClueItem>[];
  final canIncludeYear = playerCount == null || playerCount > 4;

  // 1. Release Year (disabled when playerCount is 3 or 4)
  if (canIncludeYear && cartoon.releaseYear > 0 && !clueContainsTitle(cartoon.title, cartoon.releaseYear.toString())) {
    clues.add(ClueItem(
      key: 'release_year',
      label: 'Release Year',
      value: cartoon.releaseYear.toString(),
      displayText: 'Release Year: ${cartoon.releaseYear}',
    ));
  }

  // 2. Decade (disabled when playerCount is 3 or 4)
  if (canIncludeYear && cartoon.decade.isNotEmpty && !clueContainsTitle(cartoon.title, cartoon.decade)) {
    clues.add(ClueItem(
      key: 'decade',
      label: 'Decade',
      value: cartoon.decade,
      displayText: 'Decade: ${cartoon.decade}',
    ));
  }

  // 3. Channel
  if (cartoon.channel != null &&
      cartoon.channel!.isNotEmpty &&
      !clueContainsTitle(cartoon.title, cartoon.channel!)) {
    clues.add(ClueItem(
      key: 'channel',
      label: 'Channel',
      value: cartoon.channel!,
      displayText: 'Channel: ${cartoon.channel}',
    ));
  }

  // 4. Country of Origin
  if (cartoon.countryOfOrigin != null &&
      cartoon.countryOfOrigin!.isNotEmpty &&
      !clueContainsTitle(cartoon.title, cartoon.countryOfOrigin!)) {
    clues.add(ClueItem(
      key: 'country_of_origin',
      label: 'Country of Origin',
      value: cartoon.countryOfOrigin!,
      displayText: 'Country: ${cartoon.countryOfOrigin}',
    ));
  }

  // 5. Hint
  if (cartoon.hint != null &&
      cartoon.hint!.isNotEmpty &&
      !clueContainsTitle(cartoon.title, cartoon.hint!)) {
    clues.add(ClueItem(
      key: 'hint',
      label: 'Hint',
      value: cartoon.hint!,
      displayText: 'Hint: ${cartoon.hint}',
    ));
  }

  return clues;
}

/// Formats individual movie features into punchy, keyword-based clues.
/// Uses concise labels and values instead of full sentences.
List<ClueItem> getCluesForMovie(Movie movie, {int? playerCount}) {
  if (movie.industry == Industry.shows || movie.industry == Industry.kdrama) {
    return getCluesForShow(movie, playerCount: playerCount);
  }
  if (movie.industry == Industry.cartoons) {
    return getCluesForCartoon(movie, playerCount: playerCount);
  }

  final clues = <ClueItem>[];
  final canIncludeYear = playerCount == null || playerCount > 4;

  // 1. Release Year (only included when player count is > 4)
  if (canIncludeYear && movie.releaseYear > 0 && !clueContainsTitle(movie.title, movie.releaseYear.toString())) {
    clues.add(ClueItem(
      key: 'release_year',
      label: 'Release Year',
      value: movie.releaseYear.toString(),
      displayText: 'Release Year: ${movie.releaseYear}',
    ));
  }

  // 2. Decade (only included when player count is > 4)
  if (canIncludeYear && movie.decade.isNotEmpty && !clueContainsTitle(movie.title, movie.decade)) {
    clues.add(ClueItem(
      key: 'decade',
      label: 'Decade',
      value: movie.decade,
      displayText: 'Decade: ${movie.decade}',
    ));
  }

  // 3. Hero
  if (movie.hero.isNotEmpty && !clueContainsTitle(movie.title, movie.hero)) {
    clues.add(ClueItem(
      key: 'hero',
      label: 'Hero',
      value: movie.hero,
      displayText: 'Hero: ${movie.hero}',
    ));
  }

  // 4. Director
  if (movie.director.isNotEmpty && !clueContainsTitle(movie.title, movie.director)) {
    clues.add(ClueItem(
      key: 'director',
      label: 'Director',
      value: movie.director,
      displayText: 'Director: ${movie.director}',
    ));
  }

  // 5. Genre
  if (movie.genre.isNotEmpty && !clueContainsTitle(movie.title, movie.genre)) {
    clues.add(ClueItem(
      key: 'genre',
      label: 'Genre',
      value: movie.genre,
      displayText: 'Genre: ${movie.genre}',
    ));
  }

  // 6. Hint
  if (movie.hint != null && movie.hint!.isNotEmpty && !clueContainsTitle(movie.title, movie.hint!)) {
    clues.add(ClueItem(
      key: 'hint',
      label: 'Hint',
      value: movie.hint!,
      displayText: 'Hint: ${movie.hint}',
    ));
  }

  return clues;
}

/// Picks one clue for the imposter, avoiding title leaks, ensuring true randomization,
/// and avoiding consecutive clue repeats when multiple options exist.
ClueItem? generateImposterClue(
  Movie movie, {
  double Function()? random,
  int? playerCount,
  String? previousClueKey,
}) {
  final validClues = getCluesForMovie(movie, playerCount: playerCount);
  if (validClues.isEmpty) return null;

  var pool = validClues;
  if (previousClueKey != null && validClues.any((c) => c.key != previousClueKey)) {
    pool = validClues.where((c) => c.key != previousClueKey).toList();
  }

  final rng = random ?? Random().nextDouble;
  final index = (rng() * pool.length).floor().clamp(0, pool.length - 1);
  return pool[index];
}
