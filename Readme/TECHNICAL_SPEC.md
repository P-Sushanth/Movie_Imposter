# Technical Specification

## 1. Stack

- React Native
- Expo
- TypeScript
- Expo Router if compatible with the chosen Expo template; otherwise use a simple navigation setup and document the choice
- React hooks and context or a small state store if genuinely needed
- Bundled JSON for movie metadata
- Jest or the compatible Expo testing setup for pure logic tests

Use current stable, mutually compatible package versions. Keep dependencies minimal.

## 2. Architecture principles

- Offline-first: no network calls are required for gameplay.
- No backend, authentication, accounts, or analytics in the MVP.
- Keep game logic separate from UI components.
- Keep random selection injectable so tests can be deterministic.
- Keep sensitive role assignments in memory only.
- Keep movie metadata independent from UI rendering.
- Make categories and clue templates data-driven.

## 3. Suggested project structure

```text
src/
  app/ or screens/
    HomeScreen.tsx
    CategoryScreen.tsx
    PlayersScreen.tsx
    DealCardsScreen.tsx
    DiscussionScreen.tsx
  components/
    PrimaryButton.tsx
    IndustryChip.tsx
    PlayerNameInput.tsx
    PlayerCard.tsx
    ProgressIndicator.tsx
  data/
    movies.json
    industries.ts
  domain/
    types.ts
    gameSetup.ts
    clueGenerator.ts
    movieFilter.ts
    validation.ts
  state/
    GameContext.tsx
  theme/
    colors.ts
    spacing.ts
    typography.ts
  utils/
    random.ts
  __tests__/
    gameSetup.test.ts
    clueGenerator.test.ts
    validation.test.ts
scripts/
  import-tmdb-movies.*   # later phase; not required for first playable build
```

Adjust file structure if the current Expo template uses a different convention, but preserve the separation of UI, data, and domain logic.

## 4. Core types

Define typed models equivalent to:

```ts
type Industry =
  | "tollywood"
  | "bollywood"
  | "kollywood"
  | "mollywood"
  | "sandalwood"
  | "hollywood"
  | "other_indian"
  | "other_international";

type Player = {
  id: string;
  name: string;
};

type Movie = {
  id: string;
  title: string;
  originalTitle?: string;
  originalLanguage: string;
  industry: Industry;
  releaseDate?: string;
  genres: string[];
  director?: string;
  cast: string[];
  overview?: string;
  clueFacts?: Clue[];
  metadataReviewed?: boolean;
};

type Clue = {
  type: "genre" | "release_year" | "release_decade" | "director" | "cast" | "overview";
  text: string;
};

type AssignedRole =
  | { playerId: string; kind: "movie"; movieId: string }
  | { playerId: string; kind: "imposter"; clue: string };

type RoundState = {
  movieId: string;
  players: Player[];
  assignments: AssignedRole[];
  currentCardIndex: number;
  phase: "dealing" | "discussion";
};
```

Do not store a copy of the actual movie title in the imposter's assignment. Keep the role assignment representation minimal. The selected movie will still exist in round state, so the UI must not render it during the imposter's card.

## 5. State transitions

Expected flow:

`home -> categories -> players -> dealing -> discussion`

Allowed actions:
- Select / deselect categories
- Add / edit / remove player
- Start round
- Reveal current player's card
- Hide card and continue
- Restart round
- Return home

Validate each transition. Do not allow starting a round with invalid input.

## 6. Data filtering

- Filter by `industry`, not only by language code.
- For Mixed mode, use the union of all selected industry categories.
- Avoid duplicate records.
- Exclude malformed movies and records with no valid clue path.
- Keep the category list and display labels in one shared definition.

## 7. Android build

Document how to:
1. Install dependencies.
2. Run the app locally.
3. Run type checks and tests.
4. Test on an Android emulator or physical device.
5. Configure an EAS project if required.
6. Build an installable Android APK suitable for sharing through GitHub Releases.

Do not claim an APK has been built unless the build actually succeeds. Never commit signing keys, tokens, `.env` files, or API credentials.

## 8. Error handling

Use clear user-facing errors. Avoid raw exceptions in the UI. If movie filtering returns no valid data, explain that no movies are available in the selected categories and offer a route back to category selection.
