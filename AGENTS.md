# Instructions for Antigravity

You are implementing **Imposter Who?**, an Android-first, offline Indian cinema party game. Read every project specification before making architectural decisions.

## Read these files in order

1. `PRODUCT_SPEC.md`
2. `GAME_RULES.md`
3. `MOVIE_DATA.md`
4. `TECHNICAL_SPEC.md`
5. `UI_UX_SPEC.md`
6. `TEST_PLAN.md`
7. `ROADMAP.md`

## Required behavior

- Use React Native, Expo, and TypeScript.
- Use a simple, maintainable architecture. Avoid unnecessary abstractions.
- Build a polished mobile UI, not a web page squeezed into a phone.
- Use local game state and bundled JSON data. No backend or accounts.
- The core game must work entirely offline.
- Make role assignment and card reveal privacy-safe: never show all roles together on a shared screen.
- Keep game rules and clue generation deterministic and unit-testable.
- Use original text and simple shapes. Do not download or bundle movie posters, screenshots, film logos, dialogue, or audio.
- Include a small, clearly labelled sample movie dataset for development. Do not pretend it is a complete or authoritative database.
- Support category filtering and Mixed mode.
- Do not implement a scoreboard, online multiplayer, ads, subscriptions, or social features in this MVP.

## Build process

Implement in the phases listed in `ROADMAP.md`.

For each phase:
1. State what you plan to implement.
2. Make the changes.
3. Run TypeScript checks, linting if configured, and relevant tests.
4. Fix errors before proceeding.
5. Summarize changed files and how to run the app.

Do not leave core flows as TODOs, fake buttons, or placeholder screens. If a feature is out of MVP scope, omit it rather than adding a non-functional control.

## Project setup

Use Expo's current stable TypeScript template and compatible package versions. Do not guess obsolete APIs. Keep dependencies minimal and document any additional dependency.

The app should launch in Expo Go during development where feasible. Document the exact commands to run locally and the steps to build an Android APK with EAS Build. Do not commit secrets or API credentials.

## Definition of done

The app passes the acceptance criteria in `TEST_PLAN.md`, can play a full round with 3–10 players, supports offline play, and has clear instructions for creating a distributable Android build.
