import { getCluesForMovie, generateImposterClue } from "../data/movies/clueTemplates";
import { Movie } from "../data/movies/types";

describe("Clue Generation", () => {
  const sampleMovie: Movie = {
    id: "test-001",
    title: "Pokiri",
    industry: "tollywood",
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

  it("produces all 4 clues (hero, director, genre, hint) for movies with hint", () => {
    const movieWithHint: Movie = {
      id: "tollywood-001",
      title: "Badri",
      industry: "tollywood",
      hero: "Pawan Kalyan",
      director: "Puri Jagannadh",
      genre: "Action Romance",
      hint: "Bay Of Bengal",
    };

    const clues = getCluesForMovie(movieWithHint);
    const keys = clues.map((c) => c.key);
    expect(keys).toEqual(["hero", "director", "genre", "hint"]);
    expect(clues.find((c) => c.key === "hint")?.displayText).toBe("Hint: Bay Of Bengal");
    expect(keys).not.toContain("release_year");
    expect(keys).not.toContain("decade");
  });

  it("generates show clues for kdrama", () => {
    const sampleKdrama: Movie = {
      id: "kdrama-001",
      title: "Squid Game",
      industry: "kdrama",
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
    expect(keys).not.toContain("release_year");
    expect(keys).not.toContain("decade");
  });

  it("never includes release_year or decade regardless of player count", () => {
    const movieWithHint: Movie = {
      id: "tollywood-001",
      title: "Badri",
      industry: "tollywood",
      hero: "Pawan Kalyan",
      director: "Puri Jagannadh",
      genre: "Action Romance",
      hint: "Bay Of Bengal",
    };

    for (const pCount of [3, 4, 5, 8]) {
      const clues = getCluesForMovie(movieWithHint, pCount);
      const keys = clues.map((c) => c.key);
      expect(keys).not.toContain("release_year");
      expect(keys).not.toContain("decade");
      expect(keys).toEqual(["hero", "director", "genre", "hint"]);
    }
  });

  it("avoids repeating previousClueKey when multiple clues are available", () => {
    const movieWithHint: Movie = {
      id: "tollywood-001",
      title: "Badri",
      industry: "tollywood",
      hero: "Pawan Kalyan",
      director: "Puri Jagannadh",
      genre: "Action Romance",
      hint: "Bay Of Bengal",
    };

    for (let i = 0; i < 20; i++) {
      const clue = generateImposterClue(movieWithHint, Math.random, 5, "genre");
      expect(clue?.key).not.toBe("genre");
    }
  });

  it("generates cartoon clues (channel, countryOfOrigin, hint) for cartoons", () => {
    const sampleCartoon: Movie = {
      id: "cartoons-001",
      title: "Doraemon",
      industry: "cartoons",
      channel: "Hungama TV",
      countryOfOrigin: "Japan",
      hint: "Pipes",
    };

    const clues = getCluesForMovie(sampleCartoon);
    const keys = clues.map((c) => c.key);
    expect(keys).toEqual(["channel", "country_of_origin", "hint"]);
    expect(clues.find((c) => c.key === "channel")?.displayText).toBe("Channel: Hungama TV");
    expect(clues.find((c) => c.key === "country_of_origin")?.displayText).toBe("Country: Japan");
    expect(clues.find((c) => c.key === "hint")?.displayText).toBe("Hint: Pipes");
    expect(keys).not.toContain("release_year");
    expect(keys).not.toContain("decade");
  });
});
