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
  previousClueKey?: string;
  usedMovieIds?: Set<string>;
  random?: () => number;
}

export function createRound({
  players,
  selectedIndustries,
  moviePool,
  numImposters = 1,
  imposterClueEnabled = true,
  previousMovieId,
  previousClueKey,
  usedMovieIds,
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
  const poolMatchingIndustries = moviePool.filter((m) => industrySet.has(m.industry));

  if (poolMatchingIndustries.length === 0) {
    throw new Error("No eligible movies found for the selected industries.");
  }

  // 5. Exclude movies already played in this session
  let eligibleMovies = poolMatchingIndustries.filter(
    (m) => !(usedMovieIds?.has(m.id) ?? false)
  );

  // If all movies for selected industries have been exhausted in this session, recycle pool
  if (eligibleMovies.length === 0) {
    if (usedMovieIds) {
      for (const m of poolMatchingIndustries) {
        usedMovieIds.delete(m.id);
      }
    }
    eligibleMovies = poolMatchingIndustries;
  }

  // 6. Avoid repeating previous movie if alternatives exist
  if (previousMovieId && eligibleMovies.length > 1) {
    const withoutPrevious = eligibleMovies.filter((m) => m.id !== previousMovieId);
    if (withoutPrevious.length > 0) {
      eligibleMovies = withoutPrevious;
    }
  }

  // 7. Select movie and (if clue enabled) generate clue
  let selectedMovie: Movie | null = null;
  let imposterClue: ReturnType<typeof generateImposterClue> = null;

  const candidatePool = [...eligibleMovies];

  while (candidatePool.length > 0 && !selectedMovie) {
    const movieIndex = Math.floor(random() * candidatePool.length);
    const candidate = candidatePool.splice(movieIndex, 1)[0];

    if (imposterClueEnabled) {
      const clue = generateImposterClue(
        candidate,
        random,
        resolvedPlayers.length,
        previousClueKey
      );
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

  // 8. Pick distinct imposter indices uniformly at random
  const allIndices = Array.from({ length: resolvedPlayers.length }, (_, i) => i);
  const imposterIndices = new Set<number>();

  while (imposterIndices.size < safeNumImposters && allIndices.length > 0) {
    const pickIdx = Math.floor(random() * allIndices.length);
    const chosen = allIndices.splice(pickIdx, 1)[0];
    imposterIndices.add(chosen);
  }

  // 9. Always randomize the dealing order so no player always goes first or last
  const dealingIndices = Array.from({ length: resolvedPlayers.length }, (_, i) => i);
  for (let i = dealingIndices.length - 1; i > 0; i--) {
    const j = Math.floor(random() * (i + 1));
    const temp = dealingIndices[i];
    dealingIndices[i] = dealingIndices[j];
    dealingIndices[j] = temp;
  }

  // 10. Assign roles in the randomized dealing order
  const imposterNames: string[] = [];
  for (const idx of imposterIndices) {
    imposterNames.push(resolvedPlayers[idx]);
  }

  const assignments: PlayerAssignment[] = dealingIndices.map((index) => {
    const name = resolvedPlayers[index];
    const playerId = `player-${index + 1}`;
    if (imposterIndices.has(index)) {
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

  // 11. Choose a random starting player and randomize discussion turn order
  const discussionOrder = [...resolvedPlayers];
  for (let i = discussionOrder.length - 1; i > 0; i--) {
    const j = Math.floor(random() * (i + 1));
    const temp = discussionOrder[i];
    discussionOrder[i] = discussionOrder[j];
    discussionOrder[j] = temp;
  }
  const startingPlayer = discussionOrder[0];

  return {
    movieId: selectedMovie.id,
    movieTitle: selectedMovie.title,
    industry: selectedMovie.industry,
    players: resolvedPlayers,
    imposters: imposterNames,
    numImposters: safeNumImposters,
    imposterClueEnabled,
    imposterClueKey: imposterClue?.key,
    assignments,
    startingPlayer,
    discussionOrder,
    currentCardIndex: 0,
    phase: "dealing",
  };
}
