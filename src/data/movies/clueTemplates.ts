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
 * Formats individual movie features into punchy, keyword-based clues.
 * Uses concise labels and values instead of full sentences.
 */
export function getCluesForMovie(movie: Movie): ClueItem[] {
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

  // 5. Is Adult
  const adultValue = movie.isAdult ? "Adult (A)" : "Universal (U/UA)";
  clues.push({
    key: "is_adult",
    label: "Rating",
    value: adultValue,
    displayText: `Rating: ${adultValue}`,
  });

  // 6. Is Remake
  const remakeValue = movie.isRemake ? "Remake" : "Original";
  clues.push({
    key: "is_remake",
    label: "Story Type",
    value: remakeValue,
    displayText: `Story Type: ${remakeValue}`,
  });

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
