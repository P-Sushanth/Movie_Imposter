export type Industry =
  | "tollywood"
  | "bollywood"
  | "hollywood"
  | "shows"
  | "kdrama"
  | "kollywood"
  | "mollywood"
  | "sandalwood";

export type ClueFeatureKey =
  | "release_year"
  | "decade"
  | "hero"
  | "director"
  | "genre"
  | "hint"
  | "production_house"
  | "seasons_count"
  | "start_year"
  | "end_year"
  | "adaptation_or_original"
  | "release_medium";

export interface Movie {
  id: string;
  title: string;
  industry: Industry;
  releaseYear: number;
  decade: string;
  hero?: string;
  director?: string;
  genre?: string;
  hint?: string;
  productionHouse?: string;
  seasonsCount?: number;
  startYear?: number;
  endYear?: string;
  adaptationOrOriginal?: string;
  releaseMedium?: string;
}

export interface ClueItem {
  key: ClueFeatureKey;
  label: string;
  value: string;
  displayText: string; // e.g. "Hero: Shah Rukh Khan"
}
