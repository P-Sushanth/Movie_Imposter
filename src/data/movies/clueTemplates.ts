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
export function getCluesForShow(show: Movie): ClueItem[] {
  const clues: ClueItem[] = [];

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

  // 3. Start Year
  const startYr = show.startYear ?? show.releaseYear;
  clues.push({
    key: "start_year",
    label: "Start Year",
    value: `${startYr}`,
    displayText: `Start Year: ${startYr}`,
  });

  // 4. End Year
  if (show.endYear) {
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
 * Formats individual movie features into punchy, keyword-based clues.
 * Uses concise labels and values instead of full sentences.
 */
export function getCluesForMovie(movie: Movie): ClueItem[] {
  if (movie.industry === "shows") {
    return getCluesForShow(movie);
  }

  const clues: ClueItem[] = [];

  // 1. Decade
  if (movie.decade && !clueContainsTitle(movie.title, movie.decade)) {
    clues.push({
      key: "decade",
      label: "Decade",
      value: movie.decade,
      displayText: `Decade: ${movie.decade}`,
    });
  }

  // 2. Hero
  if (movie.hero && !clueContainsTitle(movie.title, movie.hero)) {
    clues.push({
      key: "hero",
      label: "Hero",
      value: movie.hero,
      displayText: `Hero: ${movie.hero}`,
    });
  }

  // 3. Director
  if (movie.director && !clueContainsTitle(movie.title, movie.director)) {
    clues.push({
      key: "director",
      label: "Director",
      value: movie.director,
      displayText: `Director: ${movie.director}`,
    });
  }

  // 4. Genre
  if (movie.genre && !clueContainsTitle(movie.title, movie.genre)) {
    clues.push({
      key: "genre",
      label: "Genre",
      value: movie.genre,
      displayText: `Genre: ${movie.genre}`,
    });
  }

  return clues;
}

/**
 * Picks one clue for the imposter, avoiding title leaks and allowing an injectable random function.
 */
export function generateImposterClue(
  movie: Movie,
  random: () => number = Math.random
): ClueItem | null {
  const validClues = getCluesForMovie(movie);
  if (validClues.length === 0) return null;

  const index = Math.floor(random() * validClues.length);
  return validClues[index];
}
