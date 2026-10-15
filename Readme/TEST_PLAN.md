# Test Plan and Acceptance Criteria

## 1. Unit tests

### Player validation
- Reject fewer than 3 players.
- Reject more than 10 players.
- Reject empty or whitespace-only names.
- Detect duplicate names ignoring case and surrounding whitespace.
- Accept valid distinct names.

### Movie filtering
- Tollywood selection returns only `industry: "tollywood"` movies.
- Multi-select returns the union of selected industries.
- Mixed selection returns all supported selected industries.
- Malformed movies and movies with no possible clue are excluded.
- Empty results are handled without crashing.

### Role assignment
- Exactly one imposter is assigned.
- Every player is assigned exactly one role.
- Every non-imposter receives the same selected movie ID.
- The imposter receives a clue and is not assigned a normal movie card.
- All player IDs in assignments exist in the player list.
- Injected random selection makes tests deterministic.
- Starting a new round can select a different movie when multiple eligible movies exist.

### Clue generation
- Produces a non-empty clue when valid metadata exists.
- Uses fallback metadata when the preferred clue source is absent.
- Never intentionally includes the movie title or obvious title fragments.
- Handles missing genre, date, director, cast, and overview.
- Does not emit a blank or undefined string.
- Does not include dialogue or lyrics.

## 2. Manual acceptance tests

1. Launch the app with no internet connection.
2. Select Tollywood and start a game with three players.
3. Confirm the app refuses to start with fewer than three valid names.
4. Start a round and reveal each card one at a time.
5. Confirm normal players see the same movie title.
6. Confirm exactly one player sees an imposter clue.
7. Hide every card and confirm no secret content remains on screen.
8. Reach the discussion screen and confirm it does not reveal the movie or imposter.
9. Start a new round and verify roles are reassigned.
10. Select Bollywood and verify only Bollywood-category records are eligible.
11. Select multiple categories and verify mixed selection works.
12. Select a category with no eligible data and verify a clear recovery path.
13. Background the app while a card is revealed; confirm the card is hidden when the app resumes where supported.
14. Test on a small Android screen and a typical phone screen.
15. Build an APK and install it on a physical Android device.

## 3. Release acceptance criteria

The MVP is ready when:
- All core screens and transitions work.
- The game completes with 3–10 players.
- Exactly one imposter is assigned each round.
- The app works offline.
- No backend or API credential is required at runtime.
- No role overview is exposed.
- Unit tests for validation, filtering, assignment, and clue generation pass.
- Setup and Android APK build instructions are documented.
