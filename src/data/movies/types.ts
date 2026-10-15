export type Industry =
  | "tollywood"
  | "bollywood"
  | "hollywood"
  | "kollywood"
  | "mollywood"
  | "sandalwood";

export type ClueFeatureKey =
  | "decade"
  | "hero"
  | "director"
  | "genre"
  | "is_adult"
  | "is_remake";

export interface Movie {
  id: string;
  title: string;
  industry: Industry;
  releaseYear: number;
  decade: string;
  hero: string;
  director: string;
  genre: string;
  isAdult: boolean;
  isRemake: boolean;
}

export interface ClueItem {
  key: ClueFeatureKey;
  label: string;
  value: string;
  displayText: string; // e.g. "Hero: Shah Rukh Khan"
}
