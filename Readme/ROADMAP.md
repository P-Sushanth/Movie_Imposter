# Implementation Roadmap

Build in phases. Do not start later phases until the current phase runs and its acceptance checks pass.

## Phase 1 — App scaffold
- Create an Expo + React Native + TypeScript app.
- Set up navigation and shared theme tokens.
- Create placeholder screens with working navigation.
- Add scripts for type checking and tests.
- Verify launch on an Android emulator or device.

**Exit condition:** App launches and navigation works.

## Phase 2 — Setup flow
- Home screen.
- Industry selection and multi-select.
- Player entry for 3–10 players.
- Validation for blank and duplicate names.
- Empty-category recovery UI.

**Exit condition:** Valid setup can reach the round start; invalid setup cannot.

## Phase 3 — Game engine
- Typed movie schema and local JSON fixtures.
- Movie filtering by selected industry.
- Random movie selection.
- Random assignment of exactly one imposter.
- Clue-generation function with fallbacks.
- Unit tests for validation, filtering, and assignments.

**Exit condition:** Game logic works independently of the UI and tests pass.

## Phase 4 — Card dealing and discussion
- Private card hand-off screen.
- Reveal and hide behavior.
- Normal-player movie card.
- Imposter clue card.
- Progress indicator.
- Discussion screen with no answer reveal.
- New-round and home actions.
- Hide sensitive card content on background/navigation where practical.

**Exit condition:** A complete round can be played locally.

## Phase 5 — Dataset quality
- Expand the local dataset to 20–30 verified movies across at least three industries.
- Review industry labels and metadata.
- Check generated clues for accidental title leaks.
- Add data validation to catch malformed entries.
- Document TMDB attribution and terms as applicable.

**Exit condition:** Dataset is usable, valid, and included in the app bundle.

## Phase 6 — Polish and verification
- Improve spacing, typography, contrast, and touch targets.
- Test small screens and Android Back behavior.
- Run all tests and type checks.
- Test in airplane mode.
- Fix crashes, dead buttons, and exposed card content.

**Exit condition:** All acceptance criteria in `TEST_PLAN.md` pass.

## Phase 7 — Distribution
- Document EAS setup and Android APK build steps.
- Build an APK.
- Install and test the actual APK on a physical device.
- Add GitHub Release instructions.
- Keep secrets and signing credentials out of the repository.

**Exit condition:** A tested APK can be shared from GitHub Releases.

## After MVP — not now
Possible future work:
- Scoreboard and round history.
- More game modes (emoji guessing, director guessing, trivia).
- Difficulty levels and clue tuning.
- More industries and languages.
- Daily challenge.
- Online multiplayer and room codes.
- Community-submitted movie data.
- Web/PWA version.
- Optional backend for synced content.

Do not implement these future features during the MVP unless the user explicitly changes the scope.
