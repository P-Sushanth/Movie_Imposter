import { ClueFeatureKey, ClueItem, Movie } from "./types";

/**
 * Checks if a candidate clue text accidentally contains the movie title.
 */
function clueContainsTitle(title: string, value: string): boolean {
  if (!title || !value) return false;
  const cleanTitle = title.trim().toLowerCase();
  const cleanVal = value.trim().toLowerCase();
  if (cleanVal.length >= 3 && cleanTitle.length >= 3) {
    if (cleanVal.includes(cleanTitle) || cleanTitle.includes(cleanVal)) {
      return true;
    }
  }
  return false;
}

/**
 * Formats show features into show-specific clues:
 * Production House, Number of Seasons, Start year, End year,
 * Adaptation or Original, TV release or OTT release, and Premise line.
 */
export function getCluesForShow(show: Movie, playerCount?: number): ClueItem[] {
  const clues: ClueItem[] = [];
  const canIncludeYear = playerCount === undefined || playerCount > 4;

  // 1. Production House (Platform)
  if (show.productionHouse && !clueContainsTitle(show.title, show.productionHouse)) {
    clues.push({
      key: "production_house",
      label: "Production House",
      value: show.productionHouse,
      displayText: `Production House: ${show.productionHouse}`,
    });
  }

  // 2. Number of Seasons
  if (show.seasonsCount !== undefined && show.seasonsCount !== null) {
    const sText = `${show.seasonsCount} ${show.seasonsCount === 1 ? "Season" : "Seasons"}`;
    clues.push({
      key: "seasons_count",
      label: "Number of Seasons",
      value: sText,
      displayText: `Number of Seasons: ${sText}`,
    });
  }

  // 3. Start Year (only included when player count is > 4)
  if (canIncludeYear) {
    const startYr = show.startYear ?? show.releaseYear;
    clues.push({
      key: "start_year",
      label: "Start Year",
      value: `${startYr}`,
      displayText: `Start Year: ${startYr}`,
    });
  }

  // 4. End Year (only included when player count is > 4)
  if (canIncludeYear && show.endYear) {
    clues.push({
      key: "end_year",
      label: "End Year",
      value: show.endYear,
      displayText: `End Year: ${show.endYear}`,
    });
  }

  // 5. Adaptation or Original
  if (show.adaptationOrOriginal) {
    clues.push({
      key: "adaptation_or_original",
      label: "Adaptation / Original",
      value: show.adaptationOrOriginal,
      displayText: `Story: ${show.adaptationOrOriginal}`,
    });
  }

  // 6. TV release or OTT release
  if (show.releaseMedium) {
    clues.push({
      key: "release_medium",
      label: "Release Type",
      value: show.releaseMedium,
      displayText: `Release: ${show.releaseMedium}`,
    });
  }

  return clues;
}

/**
 * Formats cartoon features into cartoon-specific clues:
 * Release Year, Decade, Channel, Country of Origin, and Hint.
 */
export function getCluesForCartoon(cartoon: Movie, playerCount?: number): ClueItem[] {
  const clues: ClueItem[] = [];
  const canIncludeYear = playerCount === undefined || playerCount > 4;

  // 1. Release Year (disabled when playerCount is 3 or 4)
  if (canIncludeYear && cartoon.releaseYear && !clueContainsTitle(cartoon.title, String(cartoon.releaseYear))) {
    clues.push({
      key: "release_year",
      label: "Release Year",
      value: String(cartoon.releaseYear),
      displayText: `Release Year: ${cartoon.releaseYear}`,
    });
  }

  // 2. Decade (disabled when playerCount is 3 or 4)
  if (canIncludeYear && cartoon.decade && !clueContainsTitle(cartoon.title, cartoon.decade)) {
    clues.push({
      key: "decade",
      label: "Decade",
      value: cartoon.decade,
      displayText: `Decade: ${cartoon.decade}`,
    });
  }

  // 3. Channel
  if (cartoon.channel && !clueContainsTitle(cartoon.title, cartoon.channel)) {
    clues.push({
      key: "channel",
      label: "Channel",
      value: cartoon.channel,
      displayText: `Channel: ${cartoon.channel}`,
    });
  }

  // 4. Country of Origin
  if (cartoon.countryOfOrigin && !clueContainsTitle(cartoon.title, cartoon.countryOfOrigin)) {
    clues.push({
      key: "country_of_origin",
      label: "Country of Origin",
      value: cartoon.countryOfOrigin,
      displayText: `Country: ${cartoon.countryOfOrigin}`,
    });
  }

  // 5. Hint
  if (cartoon.hint && !clueContainsTitle(cartoon.title, cartoon.hint)) {
    clues.push({
      key: "hint",
      label: "Hint",
      value: cartoon.hint,
      displayText: `Hint: ${cartoon.hint}`,
    });
  }

  return clues;
}

/**
 * Formats individual movie features into punchy, keyword-based clues.
 * Uses concise labels and values instead of full sentences.
 */
export function getCluesForMovie(movie: Movie, playerCount?: number): ClueItem[] {
  if (movie.industry === "shows" || movie.industry === "kdrama") {
    return getCluesForShow(movie, playerCount);
  }
  if (movie.industry === "cartoons") {
    return getCluesForCartoon(movie, playerCount);
  }

  const clues: ClueItem[] = [];
  const canIncludeYear = playerCount === undefined || playerCount > 4;

  // 1. Release Year (only included when player count is > 4)
  if (canIncludeYear && movie.releaseYear && !clueContainsTitle(movie.title, String(movie.releaseYear))) {
    clues.push({
      key: "release_year",
      label: "Release Year",
      value: String(movie.releaseYear),
      displayText: `Release Year: ${movie.releaseYear}`,
    });
  }

  // 2. Decade (only included when player count is > 4)
  if (canIncludeYear && movie.decade && !clueContainsTitle(movie.title, movie.decade)) {
    clues.push({
      key: "decade",
      label: "Decade",
      value: movie.decade,
      displayText: `Decade: ${movie.decade}`,
    });
  }

  // 3. Hero
  if (movie.hero && !clueContainsTitle(movie.title, movie.hero)) {
    clues.push({
      key: "hero",
      label: "Hero",
      value: movie.hero,
      displayText: `Hero: ${movie.hero}`,
    });
  }

  // 4. Director
  if (movie.director && !clueContainsTitle(movie.title, movie.director)) {
    clues.push({
      key: "director",
      label: "Director",
      value: movie.director,
      displayText: `Director: ${movie.director}`,
    });
  }

  // 5. Genre
  if (movie.genre && !clueContainsTitle(movie.title, movie.genre)) {
    clues.push({
      key: "genre",
      label: "Genre",
      value: movie.genre,
      displayText: `Genre: ${movie.genre}`,
    });
  }

  // 6. Hint
  if (movie.hint && !clueContainsTitle(movie.title, movie.hint)) {
    clues.push({
      key: "hint",
      label: "Hint",
      value: movie.hint,
      displayText: `Hint: ${movie.hint}`,
    });
  }

  return clues;
}

/**
 * Picks one clue for the imposter, avoiding title leaks, ensuring true randomization,
 * and avoiding consecutive clue repeats when multiple options exist.
 */
export function generateImposterClue(
  movie: Movie,
  random: () => number = Math.random,
  playerCount?: number,
  previousClueKey?: string
): ClueItem | null {
  const validClues = getCluesForMovie(movie, playerCount);
  if (validClues.length === 0) return null;

  let pool = validClues;
  if (previousClueKey && validClues.some((c) => c.key !== previousClueKey)) {
    pool = validClues.filter((c) => c.key !== previousClueKey);
  }

  const index = Math.floor(random() * pool.length);
  return pool[index];
}
