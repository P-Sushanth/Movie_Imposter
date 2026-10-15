import { Industry, Movie } from "../data/movies/types";
import { generateImposterClue } from "../data/movies/clueTemplates";
import { PlayerAssignment, RoundState } from "./types";
import { resolvePlayerNames, validatePlayers } from "./validation";

export interface CreateRoundParams {
  players: string[];
  selectedIndustries: Industry[];
  moviePool: Movie[];
  numImposters?: number;
  imposterClueEnabled?: boolean;
  previousMovieId?: string;
  random?: () => number;
}

export function createRound({
  players,
  selectedIndustries,
  moviePool,
  numImposters = 1,
  imposterClueEnabled = true,
  previousMovieId,
  random = Math.random,
}: CreateRoundParams): RoundState {
  // 1. Resolve default player names (e.g. blank -> "Player 1")
  const resolvedPlayers = resolvePlayerNames(players);

  // 2. Validate players
  const playerValidation = validatePlayers(resolvedPlayers);
  if (!playerValidation.isValid) {
    throw new Error(playerValidation.error || "Invalid player list");
  }

  // 3. Validate imposters count
  const safeNumImposters = Math.max(
    1,
    Math.min(numImposters, Math.floor(resolvedPlayers.length / 2))
  );

  // 4. Filter movies by selected industries
  const industrySet = new Set(selectedIndustries);
  let eligibleMovies = moviePool.filter((m) => industrySet.has(m.industry));

  if (eligibleMovies.length === 0) {
    throw new Error("No eligible movies found for the selected industries.");
  }

  // 5. Avoid repeating previous movie if alternatives exist
  if (previousMovieId && eligibleMovies.length > 1) {
    const withoutPrevious = eligibleMovies.filter((m) => m.id !== previousMovieId);
    if (withoutPrevious.length > 0) {
      eligibleMovies = withoutPrevious;
    }
  }

  // 6. Select movie and (if clue enabled) generate clue
  let selectedMovie: Movie | null = null;
  let imposterClue: ReturnType<typeof generateImposterClue> = null;

  const candidatePool = [...eligibleMovies];

  while (candidatePool.length > 0 && !selectedMovie) {
    const movieIndex = Math.floor(random() * candidatePool.length);
    const candidate = candidatePool.splice(movieIndex, 1)[0];

    if (imposterClueEnabled) {
      const clue = generateImposterClue(candidate, random);
      if (clue) {
        selectedMovie = candidate;
        imposterClue = clue;
        break;
      }
    } else {
      selectedMovie = candidate;
      break;
    }
  }

  if (!selectedMovie) {
    throw new Error("Failed to find an eligible movie.");
  }

  // 7. Pick distinct imposter indices uniformly at random
  const allIndices = Array.from({ length: resolvedPlayers.length }, (_, i) => i);
  const imposterIndices = new Set<number>();

  while (imposterIndices.size < safeNumImposters && allIndices.length > 0) {
    const pickIdx = Math.floor(random() * allIndices.length);
    const chosen = allIndices.splice(pickIdx, 1)[0];
    imposterIndices.add(chosen);
  }

  // 8. Assign roles
  const imposterNames: string[] = [];
  const assignments: PlayerAssignment[] = resolvedPlayers.map((name, index) => {
    const playerId = `player-${index + 1}`;
    if (imposterIndices.has(index)) {
      imposterNames.push(name);
      return {
        playerId,
        playerName: name,
        role: {
          kind: "imposter",
          clueText: imposterClueEnabled && imposterClue ? imposterClue.displayText : undefined,
          clueLabel: imposterClueEnabled && imposterClue ? imposterClue.label : undefined,
        },
      };
    } else {
      return {
        playerId,
        playerName: name,
        role: {
          kind: "movie",
          movieTitle: selectedMovie!.title,
          industry: selectedMovie!.industry,
        },
      };
    }
  });

  return {
    movieId: selectedMovie.id,
    movieTitle: selectedMovie.title,
    industry: selectedMovie.industry,
    players: resolvedPlayers,
    imposters: imposterNames,
    numImposters: safeNumImposters,
    imposterClueEnabled,
    assignments,
    currentCardIndex: 0,
    phase: "dealing",
  };
}
