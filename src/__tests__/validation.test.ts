import { validatePlayers, resolvePlayerNames } from "../domain/validation";

describe("Player Validation", () => {
  it("rejects fewer than 3 players", () => {
    expect(validatePlayers(["Alice", "Bob"]).isValid).toBe(false);
    expect(validatePlayers(["Alice"]).isValid).toBe(false);
    expect(validatePlayers([]).isValid).toBe(false);
  });

  it("rejects more than 10 players", () => {
    const eleven = Array.from({ length: 11 }, (_, i) => `Player ${i + 1}`);
    expect(validatePlayers(eleven).isValid).toBe(false);
  });

  it("automatically resolves empty or whitespace-only names to Player X", () => {
    const resolved = resolvePlayerNames(["Alice", "", "   ", "David"]);
    expect(resolved).toEqual(["Alice", "Player 2", "Player 3", "David"]);

    // Valid when resolved names don't conflict
    expect(validatePlayers(["Alice", "", "Charlie"]).isValid).toBe(true);
  });

  it("detects duplicate names after resolution ignoring case", () => {
    // Explicit duplicate
    expect(validatePlayers(["Alice", "alice", "Charlie"]).isValid).toBe(false);
    // Conflict when user explicitly typed "Player 2" and left row 2 blank (resolving to Player 2)
    expect(validatePlayers(["Player 2", "", "Charlie"]).isValid).toBe(false);
  });

  it("accepts valid distinct names between 3 and 10 players", () => {
    const validThree = validatePlayers(["Venkatesh", "Nagarjuna", "Chiranjeevi"]);
    expect(validThree.isValid).toBe(true);

    const validTen = Array.from({ length: 10 }, (_, i) => `Player ${i + 1}`);
    expect(validatePlayers(validTen).isValid).toBe(true);
  });
});
