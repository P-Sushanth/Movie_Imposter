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

  it("excludes releaseYear and decade when playerCount <= 4 (e.g. 3 or 4 players)", () => {
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

    const clues3 = getCluesForMovie(movieWithHint, 3);
    const keys3 = clues3.map((c) => c.key);
    expect(keys3).not.toContain("release_year");
    expect(keys3).not.toContain("decade");
    expect(keys3).toEqual(["hero", "director", "genre", "hint"]);

    const clues4 = getCluesForMovie(movieWithHint, 4);
    const keys4 = clues4.map((c) => c.key);
    expect(keys4).not.toContain("release_year");
    expect(keys4).not.toContain("decade");
  });

  it("includes releaseYear and decade when playerCount > 4 (e.g. 5+ players)", () => {
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

    const clues5 = getCluesForMovie(movieWithHint, 5);
    const keys5 = clues5.map((c) => c.key);
    expect(keys5).toContain("release_year");
    expect(keys5).toContain("decade");
    expect(keys5).toEqual(["release_year", "decade", "hero", "director", "genre", "hint"]);
  });

  it("avoids repeating previousClueKey when multiple clues are available", () => {
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

    for (let i = 0; i < 20; i++) {
      const clue = generateImposterClue(movieWithHint, Math.random, 5, "decade");
      expect(clue?.key).not.toBe("decade");
    }
  });

  it("generates cartoon clues (releaseYear, decade, channel, countryOfOrigin, hint) for cartoons", () => {
    const sampleCartoon: Movie = {
      id: "cartoons-001",
      title: "Doraemon",
      industry: "cartoons",
      releaseYear: 2005,
      decade: "2000s",
      channel: "Hungama TV",
      countryOfOrigin: "Japan",
      hint: "Pipes",
    };

    // 5+ players: all 5 clues present
    const clues5 = getCluesForMovie(sampleCartoon, 5);
    const keys5 = clues5.map((c) => c.key);
    expect(keys5).toEqual(["release_year", "decade", "channel", "country_of_origin", "hint"]);
    expect(clues5.find((c) => c.key === "channel")?.displayText).toBe("Channel: Hungama TV");
    expect(clues5.find((c) => c.key === "country_of_origin")?.displayText).toBe("Country: Japan");
    expect(clues5.find((c) => c.key === "hint")?.displayText).toBe("Hint: Pipes");

    // 3 or 4 players: release_year and decade excluded
    const clues3 = getCluesForMovie(sampleCartoon, 3);
    const keys3 = clues3.map((c) => c.key);
    expect(keys3).toEqual(["channel", "country_of_origin", "hint"]);

    const clues4 = getCluesForMovie(sampleCartoon, 4);
    const keys4 = clues4.map((c) => c.key);
    expect(keys4).toEqual(["channel", "country_of_origin", "hint"]);
  });
});
