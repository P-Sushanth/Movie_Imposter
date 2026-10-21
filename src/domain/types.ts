import { Industry } from "../data/movies/types";

export type RoleKind = "movie" | "imposter";

export interface NormalPlayerRole {
  kind: "movie";
  movieTitle: string;
  industry: Industry;
}

export interface ImposterRole {
  kind: "imposter";
  clueText?: string;
  clueLabel?: string;
  revealedMovieTitle?: string;
}

export type PlayerRole = NormalPlayerRole | ImposterRole;

export interface PlayerAssignment {
  playerId: string;
  playerName: string;
  role: PlayerRole;
}

export interface RoundState {
  movieId: string;
  movieTitle: string;
  industry: Industry;
  players: string[];
  imposters: string[]; // names of the imposters
  numImposters: number;
  imposterClueEnabled: boolean;
  revealNameToImposter: boolean;
  imposterClueKey?: string;
  assignments: PlayerAssignment[];
  startingPlayer: string;
  discussionOrder: string[];
  currentCardIndex: number;
  phase: "dealing" | "discussion";
}
