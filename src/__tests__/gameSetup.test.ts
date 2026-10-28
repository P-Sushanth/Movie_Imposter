import { createRound, createNextRound } from "../domain/gameSetup";
import { ALL_MOVIES, getMoviesByIndustries } from "../data/movies";

describe("Game Setup & Role Assignment", () => {
  const players = ["Prabhas", "Rajamouli", "Anushka", "Rana", "Tamannaah"];

  it("assigns configured number of imposters", () => {
    const roundOne = createRound({
      players,
      selectedIndustries: ["tollywood"],
      moviePool: ALL_MOVIES,
      numImposters: 1,
    });
    expect(roundOne.imposters.length).toBe(1);

    const roundTwo = createRound({
      players,
      selectedIndustries: ["tollywood"],
      moviePool: ALL_MOVIES,
      numImposters: 2,
    });
    expect(roundTwo.imposters.length).toBe(2);
    expect(roundTwo.assignments.filter((a) => a.role.kind === "imposter").length).toBe(2);
  });

  it("handles imposter clues disabled properly", () => {
    const roundNoClues = createRound({
      players,
      selectedIndustries: ["tollywood"],
      moviePool: ALL_MOVIES,
      imposterClueEnabled: false,
    });
    const imposter = roundNoClues.assignments.find((a) => a.role.kind === "imposter");
    expect(imposter).toBeDefined();
    if (imposter && imposter.role.kind === "imposter") {
      expect(imposter.role.clueText).toBeUndefined();
    }
  });

  it("handles revealNameToImposter option properly", () => {
    // Disabled by default
    const roundDefault = createRound({
      players,
      selectedIndustries: ["tollywood"],
      moviePool: ALL_MOVIES,
      revealNameToImposter: false,
    });
    const imposterDefault = roundDefault.assignments.find((a) => a.role.kind === "imposter");
    expect(imposterDefault).toBeDefined();
    if (imposterDefault && imposterDefault.role.kind === "imposter") {
      expect(imposterDefault.role.revealedMovieTitle).toBeUndefined();
    }
    expect(roundDefault.revealNameToImposter).toBe(false);

    // Enabled
    const roundRevealed = createRound({
      players,
      selectedIndustries: ["tollywood"],
      moviePool: ALL_MOVIES,
      revealNameToImposter: true,
    });
    const imposterRevealed = roundRevealed.assignments.find((a) => a.role.kind === "imposter");
    expect(imposterRevealed).toBeDefined();
    if (imposterRevealed && imposterRevealed.role.kind === "imposter") {
      expect(imposterRevealed.role.revealedMovieTitle).toBe(roundRevealed.movieTitle);
    }
    expect(roundRevealed.revealNameToImposter).toBe(true);
  });

  it("assigns the exact same movie to all non-imposters", () => {
    const round = createRound({
      players,
      selectedIndustries: ["tollywood"],
      moviePool: ALL_MOVIES,
    });

    const movieRoles = round.assignments
      .filter((a) => a.role.kind === "movie")
      .map((a) => (a.role as any).movieTitle);

    expect(movieRoles.length).toBe(players.length - 1);
    const uniqueTitles = new Set(movieRoles);
    expect(uniqueTitles.size).toBe(1);
    expect(uniqueTitles.has(round.movieTitle)).toBe(true);
  });

  it("filters movies by selected industries correctly", () => {
    const tollywoodOnly = getMoviesByIndustries(["tollywood"]);
    expect(tollywoodOnly.length).toBeGreaterThan(0);
    expect(tollywoodOnly.every((m) => m.industry === "tollywood")).toBe(true);
  });

  it("supports starting consecutive rounds without immediate movie duplication when options exist", () => {
    const round1 = createRound({
      players,
      selectedIndustries: ["tollywood"],
      moviePool: ALL_MOVIES,
      random: () => 0.1,
    });

    const round2 = createRound({
      players,
      selectedIndustries: ["tollywood"],
      moviePool: ALL_MOVIES,
      previousMovieId: round1.movieId,
      random: () => 0.1,
    });

    expect(round2.movieId).not.toBe(round1.movieId);
  });

  it("createNextRound picks a new movie from selected industries while preserving the imposter", () => {
    const round1 = createRound({
      players,
      selectedIndustries: ["tollywood", "bollywood"],
      moviePool: ALL_MOVIES,
      numImposters: 1,
      random: () => 0.2,
    });

    const nextRound = createNextRound({
      currentRound: round1,
      moviePool: ALL_MOVIES,
      usedMovieIds: new Set([round1.movieId]),
      random: () => 0.5,
    });

    // Imposters must be the same
    expect(nextRound.imposters).toEqual(round1.imposters);
    // Movie must be different
    expect(nextRound.movieId).not.toBe(round1.movieId);
    expect(["tollywood", "bollywood"]).toContain(nextRound.industry);
    // Dealing index must reset
    expect(nextRound.currentCardIndex).toBe(0);
    expect(nextRound.phase).toBe("dealing");
    // Normal players receive new movie title
    const normalAssignment = nextRound.assignments.find((a) => a.role.kind === "movie");
    expect(normalAssignment?.role.kind).toBe("movie");
    if (normalAssignment?.role.kind === "movie") {
      expect(normalAssignment.role.movieTitle).toBe(nextRound.movieTitle);
    }
  });

  it("applies weighted soft bias against previous imposters without 100% excluding them", () => {
    const testPlayers = ["Alice", "Bob", "Charlie", "David"];
    let aliceCount = 0;
    const trials = 1000;

    for (let i = 0; i < trials; i++) {
      const round = createRound({
        players: testPlayers,
        selectedIndustries: ["tollywood"],
        moviePool: ALL_MOVIES,
        numImposters: 1,
        previousImposters: ["Alice"],
      });
      if (round.imposters.includes("Alice")) {
        aliceCount++;
      }
    }

    // Theoretical probability is 0.5 / 3.5 ≈ 14.3% (~143 out of 1000).
    // Without bias it would be 25% (250).
    // Must be significantly reduced while remaining > 0 (not 100% excluded).
    expect(aliceCount).toBeGreaterThan(60);
    expect(aliceCount).toBeLessThan(220);
  });
});
