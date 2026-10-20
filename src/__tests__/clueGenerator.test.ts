import { getCluesForMovie, generateImposterClue } from "../data/movies/clueTemplates";
import { Movie } from "../data/movies/types";

describe("Clue Generation", () => {
  const sampleMovie: Movie = {
    id: "test-001",
    title: "Pokiri",
    industry: "tollywood",
    releaseYear: 2006,
    decade: "2000s",
    hero: "Mahesh Babu",
    director: "Puri Jagannadh",
    genre: "Action Thriller",
  };

  it("produces non-empty clues for all valid features", () => {
    const clues = getCluesForMovie(sampleMovie);
    expect(clues.length).toBeGreaterThan(0);
    for (const clue of clues) {
      expect(clue.displayText).toBeTruthy();
      expect(typeof clue.displayText).toBe("string");
    }
  });

  it("does not leak the movie title in any clue", () => {
    const movieWithTitleInHero: Movie = {
      id: "test-002",
      title: "Hero",
      industry: "bollywood",
      releaseYear: 1983,
      decade: "1980s",
      hero: "Hero",
      director: "Subhash Ghai",
      genre: "Action Romance",
    };

    const clues = getCluesForMovie(movieWithTitleInHero);
    const heroClues = clues.filter((c) => c.key === "hero");
    expect(heroClues.length).toBe(0); // Safely omitted to prevent title leakage!
  });

  it("generates a random clue with injected RNG", () => {
    const clueFirst = generateImposterClue(sampleMovie, () => 0.0);
    const clueLast = generateImposterClue(sampleMovie, () => 0.99);

    expect(clueFirst).toBeDefined();
    expect(clueLast).toBeDefined();
    expect(clueFirst?.displayText).toBeTruthy();
  });

  it("produces all 6 clues (releaseYear, decade, hero, director, genre, hint) for movies with hint", () => {
    const movieWithHint: Movie = {
      id: "tollywood-001",
      title: "Badri",
      industry: "tollywood",
      releaseYear: 2000,
      decade: "2000s",
      hero: "Pawan Kalyan",
      director: "Puri Jagannadh",
      genre: "Action Romance",
      hint: "Bay Of Bengal",
    };

    const clues = getCluesForMovie(movieWithHint);
    const keys = clues.map((c) => c.key);
    expect(keys).toEqual(["release_year", "decade", "hero", "director", "genre", "hint"]);
    expect(clues.find((c) => c.key === "release_year")?.displayText).toBe("Release Year: 2000");
    expect(clues.find((c) => c.key === "hint")?.displayText).toBe("Hint: Bay Of Bengal");
  });

  it("generates show clues for kdrama", () => {
    const sampleKdrama: Movie = {
      id: "kdrama-001",
      title: "Squid Game",
      industry: "kdrama",
      releaseYear: 2021,
      decade: "2020s",
      genre: "Survival Dystopian Thriller",
      productionHouse: "Netflix",
      seasonsCount: 2,
      startYear: 2021,
      endYear: "Ongoing",
      adaptationOrOriginal: "Original",
      releaseMedium: "OTT Release",
    };

    const clues = getCluesForMovie(sampleKdrama);
    const keys = clues.map((c) => c.key);
    expect(keys).toContain("production_house");
    expect(keys).toContain("seasons_count");
    expect(keys).toContain("start_year");
    expect(keys).toContain("end_year");
    expect(keys).toContain("adaptation_or_original");
    expect(keys).toContain("release_medium");
  });
});
