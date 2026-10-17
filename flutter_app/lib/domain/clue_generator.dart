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
List<ClueItem> getCluesForShow(Movie show) {
  final clues = <ClueItem>[];

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

  // 3. Start Year
  final startYr = show.startYear ?? show.releaseYear;
  clues.add(ClueItem(
    key: 'start_year',
    label: 'Start Year',
    value: '$startYr',
    displayText: 'Start Year: $startYr',
  ));

  // 4. End Year
  if (show.endYear != null && show.endYear!.isNotEmpty) {
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

/// Formats individual movie features into punchy, keyword-based clues.
/// Uses concise labels and values instead of full sentences.
List<ClueItem> getCluesForMovie(Movie movie) {
  if (movie.industry == Industry.shows) {
    return getCluesForShow(movie);
  }

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
