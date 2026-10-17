import { Industry, Movie } from "./types";
import tollywoodData from "./tollywood.json";
import bollywoodData from "./bollywood.json";
import hollywoodData from "./hollywood.json";
import showsData from "./shows.json";

export * from "./types";
export * from "./clueTemplates";

export const ALL_MOVIES: Movie[] = [
  ...(tollywoodData as Movie[]),
  ...(bollywoodData as Movie[]),
  ...(hollywoodData as Movie[]),
  ...(showsData as Movie[]),
];

/**
 * Filter movies by one or more selected industries.
 */
export function getMoviesByIndustries(industries: Industry[]): Movie[] {
  if (industries.length === 0) return [];
  const set = new Set(industries);
  return ALL_MOVIES.filter((movie) => set.has(movie.industry));
}

/**
 * Get count summary per industry.
 */
export function getMovieCounts(): Record<string, number> {
  const counts: Record<string, number> = {};
  for (const movie of ALL_MOVIES) {
    counts[movie.industry] = (counts[movie.industry] || 0) + 1;
  }
  return counts;
}
