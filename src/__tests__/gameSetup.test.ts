import { createRound } from "../domain/gameSetup";
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
});
