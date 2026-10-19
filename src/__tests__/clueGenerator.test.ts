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
});
