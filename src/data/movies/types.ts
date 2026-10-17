export type Industry =
  | "tollywood"
  | "bollywood"
  | "hollywood"
  | "shows"
  | "kollywood"
  | "mollywood"
  | "sandalwood";

export type ClueFeatureKey =
  | "decade"
  | "hero"
  | "director"
  | "genre"
  | "is_adult"
  | "is_remake"
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
  isAdult?: boolean;
  isRemake?: boolean;
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
