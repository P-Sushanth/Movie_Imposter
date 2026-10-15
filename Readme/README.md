# Imposter Who? — Antigravity Build Pack

This folder contains the product and implementation specifications for **Imposter Who?**, an offline-first Indian cinema party game.

## How to use these files in Antigravity

1. Create/open a new project folder.
2. Copy these Markdown files into the project root (or open this folder as the project).
3. Ask Antigravity to read `AGENTS.md` first and follow the documents in the order listed there.
4. Have it implement the app in small phases. Run and test after each phase rather than generating the entire app in one pass.

## MVP summary

- Mobile-first party game for friends sharing one device.
- Players enter names, select one or more cinema industries, and start a round.
- All non-imposters receive the selected movie title.
- The imposter receives a clue derived from that movie's metadata.
- Each player privately reveals and hides their own card.
- No accounts, online multiplayer, scoreboard, or backend in the MVP.
- Movie data is cached locally, so a round can be played offline.

## Platform and stack

The project is specified as an Android-first app using **React Native + Expo + TypeScript**. This suits the goal of sharing an installable Android APK through GitHub Releases. Keep the architecture portable so a web version can be added later, but do not build multiple platforms in the MVP.

## Documents

- `AGENTS.md` — instructions for Antigravity and implementation order.
- `PRODUCT_SPEC.md` — product requirements and user flows.
- `GAME_RULES.md` — game logic, role assignment, privacy, and edge cases.
- `MOVIE_DATA.md` — TMDB import strategy, local schema, and clue generation.
- `TECHNICAL_SPEC.md` — architecture, stack, project structure, and implementation details.
- `UI_UX_SPEC.md` — screens, interactions, accessibility, and visual direction.
- `TEST_PLAN.md` — acceptance criteria and test cases.
- `ROADMAP.md` — phased build plan and explicit out-of-scope items.

## Important implementation rules

- Do not put TMDB credentials in the shipped app.
- Do not make runtime TMDB requests in the MVP. Import and curate metadata during development, then bundle it locally.
- The game must work without internet access.
- Do not include copyrighted posters, film stills, logos, dialogue excerpts, or song/audio clips. Use text and original UI illustrations only.
- Treat TMDB language codes as language filters, not definitive industry labels.
- Do not claim that every clue is accurate or complete; validate metadata and provide fallbacks.
