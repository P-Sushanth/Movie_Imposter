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
  revealNameToImposter?: boolean;
  discussionTimerMinutes?: number;
  previousMovieId?: string;
  previousClueKey?: string;
  previousImposters?: string[];
  usedMovieIds?: Set<string>;
  random?: () => number;
}

export function createRound({
  players,
  selectedIndustries,
  moviePool,
  numImposters = 1,
  imposterClueEnabled = true,
  revealNameToImposter = false,
  discussionTimerMinutes = 0,
  previousMovieId,
  previousClueKey,
  previousImposters,
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

  // 8. Pick distinct imposter indices using weighted soft bias against previous imposters
  const prevImposterLower = new Set(
    (previousImposters || []).map((name) => name.trim().toLowerCase())
  );

  const availableIndices = Array.from({ length: resolvedPlayers.length }, (_, i) => i);
  const imposterIndices = new Set<number>();

  while (imposterIndices.size < safeNumImposters && availableIndices.length > 0) {
    // Candidates who were imposter in the previous round receive weight 0.5 (half as likely relative to others),
    // while others receive weight 1.0. This prevents back-to-back streaks while keeping
    // bluffing and paranoia alive because the chance is never zero.
    const weights = availableIndices.map((idx) => {
      const playerName = resolvedPlayers[idx].trim().toLowerCase();
      return prevImposterLower.has(playerName) ? 0.5 : 1.0;
    });

    const totalWeight = weights.reduce((acc, w) => acc + w, 0);
    const randomVal = random() * totalWeight;

    let cumulative = 0;
    let selectedCandidatePos = availableIndices.length - 1;
    for (let i = 0; i < availableIndices.length; i++) {
      cumulative += weights[i];
      if (randomVal <= cumulative) {
        selectedCandidatePos = i;
        break;
      }
    }

    const chosenIndex = availableIndices.splice(selectedCandidatePos, 1)[0];
    imposterIndices.add(chosenIndex);
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
          revealedMovieTitle: revealNameToImposter ? selectedMovie!.title : undefined,
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
    selectedIndustries,
    players: resolvedPlayers,
    imposters: imposterNames,
    numImposters: safeNumImposters,
    imposterClueEnabled,
    revealNameToImposter,
    discussionTimerMinutes: Math.max(0, Math.min(10, discussionTimerMinutes)),
    imposterClueKey: imposterClue?.key,
    assignments,
    startingPlayer,
    discussionOrder,
    currentCardIndex: 0,
    phase: "dealing",
  };
}

export interface CreateNextRoundParams {
  currentRound: RoundState;
  moviePool: Movie[];
  usedMovieIds?: Set<string>;
  random?: () => number;
}

export function createNextRound({
  currentRound,
  moviePool,
  usedMovieIds,
  random = Math.random,
}: CreateNextRoundParams): RoundState {
  const industries = currentRound.selectedIndustries.length > 0
    ? currentRound.selectedIndustries
    : [currentRound.industry];
  const industrySet = new Set(industries);
  const poolMatchingIndustries = moviePool.filter((m) => industrySet.has(m.industry));

  if (poolMatchingIndustries.length === 0) {
    throw new Error("No eligible movies found for the selected industries.");
  }

  let eligibleMovies = poolMatchingIndustries.filter(
    (m) => !(usedMovieIds?.has(m.id) ?? false) && m.id !== currentRound.movieId
  );

  if (eligibleMovies.length === 0) {
    usedMovieIds?.forEach((id) => {
      if (poolMatchingIndustries.some((m) => m.id === id)) {
        usedMovieIds.delete(id);
      }
    });
    eligibleMovies = poolMatchingIndustries.filter((m) => m.id !== currentRound.movieId);
    if (eligibleMovies.length === 0) {
      eligibleMovies = poolMatchingIndustries;
    }
  }

  let selectedMovie: Movie | null = null;
  let imposterClue: ReturnType<typeof generateImposterClue> = null;

  const candidatePool = [...eligibleMovies];
  while (candidatePool.length > 0 && selectedMovie === null) {
    const movieIndex = Math.min(
      candidatePool.length - 1,
      Math.floor(random() * candidatePool.length)
    );
    const candidate = candidatePool.splice(movieIndex, 1)[0];

    if (currentRound.imposterClueEnabled) {
      const clue = generateImposterClue(
        candidate,
        random,
        currentRound.players.length,
        currentRound.imposterClueKey
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
    selectedMovie = eligibleMovies[0];
  }

  const imposterSet = new Set(currentRound.imposters);
  const assignments: PlayerAssignment[] = currentRound.players.map((name, index) => {
    const playerId = `player-${index + 1}`;
    if (imposterSet.has(name)) {
      return {
        playerId,
        playerName: name,
        role: {
          kind: "imposter",
          clueText: currentRound.imposterClueEnabled && imposterClue ? imposterClue.displayText : undefined,
          clueLabel: currentRound.imposterClueEnabled && imposterClue ? imposterClue.label : undefined,
          revealedMovieTitle: currentRound.revealNameToImposter ? selectedMovie!.title : undefined,
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
    selectedIndustries: industries,
    players: currentRound.players,
    imposters: currentRound.imposters,
    numImposters: currentRound.numImposters,
    imposterClueEnabled: currentRound.imposterClueEnabled,
    revealNameToImposter: currentRound.revealNameToImposter,
    discussionTimerMinutes: currentRound.discussionTimerMinutes,
    imposterClueKey: imposterClue?.key,
    assignments,
    startingPlayer: currentRound.startingPlayer,
    discussionOrder: currentRound.discussionOrder,
    currentCardIndex: 0,
    phase: "dealing",
  };
}
