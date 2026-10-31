# 📜 Movie Imposter & Party Arcade — Project Context Log

> **Purpose:** This file documents the complete architectural history, design decisions, domain logic, codebase structure, and release workflows of the **Movie Imposter** and **Party Arcade** repository for future AI models, agents, and human developers.

---

## 1. Project Overview & Philosophy

**Movie Imposter** is an offline, pass-and-play party game arcade built with a dual-framework architecture:
1. **Flutter (Native Android)**: Primary production target for Android APK distribution.
2. **React Native (Expo + TypeScript)**: Secondary reference implementation and rapid prototyping cross-platform app.

### Core Tenets
- **100% Offline-First**: Zero backend, zero account creation, zero analytics, zero external network dependencies for gameplay.
- **Privacy-Safe Pass & Play**: Never show secret roles, movie titles, or creator words on a shared or persistent screen. A physical hold-to-reveal gesture prevents reflection leaks.
- **Deterministic & Unit-Testable Domain Logic**: All game state transitions, strike calculations, clue generators, role allocations, and scoring rules are isolated from UI rendering and fully covered by unit tests.
- **Retro Typewriter Aesthetic (60:30:10 Palette)**:
  - **60% Dominant Base**: Vintage Warm Off-White Canvas (`#F4F3ED`).
  - **30% Structural Secondary**: Warm Soft Stone Neutrals (`#E5E3D8`, `#D8D5C8`, `#1E293B`, `#0F172A`).
  - **10% Focal Accents**: Warm Amber (`#A55704`) for primary game CTAs, and Crimson/Imposter Red (`#E11D48`) for stakes and strikes.
  - **Monospace Typography**: Courier New typewriter styling with rubber-stamped text badges (e.g., `[ WORD GUESSED ]`, `[ HANGMAN EXPIRED ]`), with **zero emojis** in stamp outcomes.
- **No Copyrighted Media**: Zero downloaded or bundled movie posters, audio clips, logos, or video assets.

---

## 2. Version Evolution History

### v1.0.0 – v1.0.11: The Foundation
- Initial pass-and-play role dealing (`DealCardsScreen` with hold-to-reveal gesture).
- Curated Indian cinema trivia catalogs (Tollywood & Bollywood).
- Direct in-app APK updater (`UpdateService` using native Android `FileProvider`).
- Infinite players support and flexible imposter count calculation.
- Discussion timer with native physical vibration (`VIBRATE` permission).

### v1.1.0 – v1.2.0: Catalog Expansion
- Multi-industry selection: Added Hollywood, TV/OTT Shows, Korean Dramas (K-Drama), and Nostalgic Cartoons (over 1,100+ titles).
- Category-filtered gameplay engine.

### v1.2.1 – v1.2.4: Tactical Depth & Multi-Round
- **"Reveal Name to Imposter" modifier**: Imposter knows the title, transforming the round into high-stakes deduction and psychological bluffing.
- **Spice It Up configuration card**: Hub for gameplay modifiers.
- **Category-Filtered Next Round**: Pass the device with a fresh movie drawn strictly from active categories while keeping the imposter secret.
- **Anti-repeat clue engine**: Imposter trivia clues cycle without repetitive back-to-back features.

### v1.3.0: Player Groups & Ergonomics
- **Player Groups (`GroupService` / `groupService`)**: Save regular friend/family groups directly to local storage (`SharedPreferences` / `AsyncStorage`). Switch groups with 1 tap.
- **↕️ Unidirectional Drag Reordering**: Native drag-and-drop player list arrangement.
- **Times-Up Vibration**: Haptic alert as soon as the timer reaches `00:00`.

### v1.3.1: Competitive Balancing
- **Persistent Movie Cache (`MovieHistoryService` / `movieHistoryService`)**: Played movie IDs persist across app restarts so titles never repeat across separate sessions.
- **50% Soft Bias Against Repeating Imposters**: Weighted probability algorithm prevents the same player from being chosen as imposter in consecutive rounds while preserving paranoia.
- **Hardware Alarm Vibration (`USAGE_ALARM`)**: Maximum amplitude (`255`) vibration burst upon timer expiry.
- **5-Second Danger Red Countdown**: Discussion timer smoothly transitions to pure red (`#FF0000`) in the final 5 seconds.

### v1.4.0: Party Arcade & Hangman Battle (Major Release)
- **Party Arcade Selection Hub (`GameHubScreen`)**: Clean launcher allowing players to choose between **Movie Imposter** and **Hangman Battle**.
- **Hangman Battle Duel Mode**:
  - Two-team pass-and-play word guessing duel (`Team Popcorn` vs `Team Cinema`).
  - **Strictly Separated Two-Step Setup Flow**:
    1. **Page 1: Team Setup (`HangmanTeamSetupScreen`)**: Scoreboard, Team A/B name inputs, 1-line scoring rules, and `Enter Secret Word →` CTA.
    2. **Page 2: Word Entry (`HangmanWordEntryScreen`)**: Word Creator Spotlight banner (highlighting setting team turn), Secret Word Hero Card (with Show/Hide toggle), and up to 3 Optional Hints.
  - **Direct Arena Navigation**: Tapping `Lock Word & Pass Phone →` transitions directly into the **Guessing Arena** (`HangmanArenaScreen`).
  - **7-Strike Retro Tracker**: Interactive typewriter boxes tracking `H - A - N - G - M - A - N` strikes with crossed-out indicators.
  - **Clues Drawer & Win Deductions**: Viewing hints dynamically reduces the round win reward from `+2 Pts` to `+1 Pt`. Setting team gets `+1 Pt` if 7 strikes are reached.
  - **Multi-Round Role Swapping**: Swapping roles preserves cumulative match scores and returns directly to Word Entry for the next round.
  - **Session Re-Entry Dialog**: Returning to Game Hub and re-selecting Hangman prompts players to either **Continue Session** or **Reset & Start Fresh**.
  - **Desktop/Web Responsiveness**: Layouts are wrapped in `Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 500)...))` so cards do not stretch across wide desktop monitors.

---

## 3. Repository Architecture & File Mapping

```
Movie_Imposter/
├── App.tsx                                  # React Native Root container & state machine
├── app.json                                 # Expo configuration (v1.4.0)
├── package.json                             # React Native dependencies & scripts (v1.4.0)
├── README.md                                # Comprehensive user documentation & APK badges
├── scripts/
│   ├── build_optimized_apks.py              # Automated multi-ABI release APK compiler
│   └── gen_movies.js                        # Data compilation script for cinema datasets
├── src/                                     # React Native Implementation
│   ├── data/movies/                         # Curated JSON cinema datasets (Tollywood, etc.)
│   ├── domain/
│   │   ├── gameSetup.ts                     # Imposter role assignment & weighted bias engine
│   │   ├── hangman.ts                       # Hangman state transitions, rules, & scoring
│   │   ├── validation.ts                    # Player input validation & normalization
│   │   └── types.ts                         # TypeScript interfaces
│   ├── screens/
│   │   ├── GameHubScreen.tsx                # Party Arcade launcher (Movie Imposter / Hangman)
│   │   ├── SetupScreen.tsx                  # Movie Imposter category & player setup
│   │   ├── DealCardsScreen.tsx              # Hold-to-reveal card dealing
│   │   ├── DiscussionScreen.tsx             # Discussion timer, spotlight, & imposter reveal
│   │   ├── HangmanTeamSetupScreen.tsx       # Step 1: Scoreboard, team names, scoring rules
│   │   ├── HangmanWordEntryScreen.tsx       # Step 2: Word creator spotlight, secret word, hints
│   │   └── HangmanArenaScreen.tsx           # Step 3: Guessing arena, strikes, keypad, clues modal
│   ├── services/
│   │   ├── groupService.ts                  # AsyncStorage player groups cache
│   │   └── movieHistoryService.ts           # AsyncStorage played movie history cache
│   ├── theme/
│   │   ├── colors.ts                        # 60:30:10 palette tokens (warm amber #A55704)
│   │   └── index.ts
│   └── __tests__/                           # Jest unit test suites (42 tests)
│       ├── clueGenerator.test.ts
│       ├── gameSetup.test.ts
│       ├── groupService.test.ts
│       ├── hangman.test.ts
│       ├── movieHistoryService.test.ts
│       └── validation.test.ts
│
└── flutter_app/                             # Flutter Implementation (Android Primary)
    ├── pubspec.yaml                         # Flutter dependencies & version (1.4.0+22)
    ├── lib/
    │   ├── main.dart                        # Flutter Root State & Navigation Router
    │   ├── data/movies_data.dart            # Compiled cinema catalog
    │   ├── domain/
    │   │   ├── game_setup.dart              # Role distribution & soft bias
    │   │   ├── hangman.dart                 # Dart hangman engine & strike tracker
    │   │   └── validation.dart              # Validation utilities
    │   ├── models/                          # Movie, PlayerGroup, RoundState models
    │   ├── screens/
    │   │   ├── game_hub_screen.dart         # Party Arcade selector
    │   │   ├── setup_screen.dart            # Movie Imposter setup
    │   │   ├── deal_cards_screen.dart       # Card reveal screen
    │   │   ├── discussion_screen.dart       # Discussion timer & voting
    │   │   ├── hangman_team_setup_screen.dart # Step 1: Team Setup (Scoreboard, names)
    │   │   ├── hangman_word_entry_screen.dart # Step 2: Word Entry (Spotlight, secret word)
    │   │   └── hangman_arena_screen.dart    # Step 3: Keypad, strike lines, rubber stamp outcome
    │   ├── services/
    │   │   ├── group_service.dart           # SharedPreferences group manager
    │   │   ├── movie_history_service.dart   # SharedPreferences movie exclusion cache
    │   │   └── update_service.dart          # In-app GitHub update detector & APK installer
    │   └── theme/
    │       ├── app_colors.dart              # Theme colors (Warm Amber #A55704, canvas #F4F3ED)
    │       └── app_theme.dart               # Light theme definition
    └── test/                                # Flutter Unit & Widget Tests (67 tests)
        ├── clue_generator_test.dart
        ├── discussion_screen_test.dart
        ├── game_setup_test.dart
        ├── group_service_test.dart
        ├── hangman_test.dart
        ├── hangman_ui_test.dart             # Full widget test suite for Hangman flow
        ├── movie_history_service_test.dart
        ├── update_service_test.dart
        └── validation_test.dart
```

---

## 4. Detailed Domain Rules & Logic

### 4.1 Hangman Duel Mechanics
- **Strikes Limit**: Fixed at `7 strikes`. Incorrect guesses strike through the 7 letters of `HANGMAN`.
- **Normalization**: Letters and digits are extracted and converted to uppercase. Whitespace, dashes, colons, and punctuation are revealed automatically.
- **Scoring Engine**:
  - Guessing team solves word with `0 clues viewed` → **`+2 Points`**.
  - Guessing team solves word after opening clues → **`+1 Point`**.
  - Guessing team hits 7 strikes without solving → Setting team receives **`+1 Point`**.
- **Role Swapping**:
  ```dart
  HangmanState createNextHangmanRound(HangmanState current, HangmanRoundOutcome outcome) {
    return current.copyWith(
      settingTeam: current.settingTeam == HangmanTeamRole.teamA
          ? HangmanTeamRole.teamB
          : HangmanTeamRole.teamA,
      secretWord: '',
      clues: const [],
      guessedLetters: const {},
      cluesViewed: false,
      scoreTeamA: outcome.updatedScoreTeamA,
      scoreTeamB: outcome.updatedScoreTeamB,
    );
  }
  ```
- **Session Continuity Guard**:
  When users navigate back to the Game Hub from an ongoing Hangman match, the match state is retained. Re-selecting Hangman triggers an `AlertDialog` / `Alert.alert`:
  - **Continue Session**: Resumes the match in progress.
  - **Reset & Start Fresh**: Resets scores to 0-0 and opens a clean Team Setup screen.

### 4.2 Movie Imposter Soft Bias Algorithm
When selecting the next imposter:
- Players who were **not** the imposter in the immediately preceding round receive double probability weight (`weight = 2.0`).
- The player who was the imposter in the previous round receives half weight (`weight = 1.0`).
- This 50% weighted soft bias reduces annoying streaks while preserving paranoia (players can never be 100% certain someone won't get it twice).

### 4.3 Trivia Clue Generation
- Clues are generated dynamically from movie metadata:
  - `hero` (Lead Actor)
  - `director`
  - `genre`
  - `hint` (Iconic trivia hook)
  - Shows: `channel` (OTT platform/network), `seasons`, `productionHouse`
  - Cartoons: `channel`, `countryOfOrigin`
- **Crucial Rule**: Clues strictly omit `releaseYear` or `decade` to prevent giveaway leaks. Clues never contain the title itself.

---

## 5. UI/UX Specifications & Constraints

1. **Strictly Two Pages for Hangman Setup**:
   - **Never combine them**. Page 1 is `HangmanTeamSetupScreen`. Page 2 is `HangmanWordEntryScreen`.
   - Page 1 CTA: `Enter Secret Word →` (`#A55704`).
   - Page 2 CTA: `Lock Word & Pass Phone →` (`#A55704`).
2. **Visual Differentiation in Word Entry**:
   - **Word Creator Spotlight Banner**: Dark Slate Midnight (`#0F172A`) card with amber `SETTING TURN` pill badge and large team title.
   - **Secret Word Card**: Prominent black border (2px), black `SECRET WORD *` badge, and show/hide eye toggle button.
   - **Optional Hints Card**: Grouped neutral stone surface (`#E5E3D8`), labeled `OPTIONAL HINTS (UP TO 3)` with numbered circular badges (`1`, `2`, `3`).
3. **Single-Line Scoring Rules**:
   - The third bullet point must strictly fit onto one line across all device screen sizes:
     `• 7 strikes hit: Setting team +1 Pt`
4. **Desktop Layout Centering**:
   - All screens wrap the content in:
     ```dart
     Center(
       child: ConstrainedBox(
         constraints: const BoxConstraints(maxWidth: 500),
         child: ...
       ),
     )
     ```
   - This prevents web and desktop views from stretching wide horizontally across the monitor.
5. **No Emojis in Stamps**:
   - Outcome modals must use strict retro monospace typewriter bracket stamps:
     `[ WORD GUESSED ]`
     `[ HANGMAN EXPIRED ]`

---

## 6. Build, Test, & Release Pipeline

### 6.1 Test Commands
- **Flutter**:
  ```bash
  cd flutter_app
  flutter test
  ```
  *(Must pass all 67 unit & widget tests)*
- **React Native**:
  ```bash
  npm test -- --silent
  npx tsc --noEmit
  ```
  *(Must pass all 42 Jest tests and compile with 0 TypeScript errors)*

### 6.2 Building Optimized Production APKs
Run the release build script from project root:
```bash
python scripts/build_optimized_apks.py
```
This script runs Flutter AOT builds with symbols obfuscation and dependency bypass:
1. `flutter build apk --release --split-per-abi --obfuscate --split-debug-info=... --android-skip-build-dependency-validation`
2. `flutter build apk --release --obfuscate --split-debug-info=... --android-skip-build-dependency-validation`
3. Copies generated APKs into standardized release asset names inside `flutter_app/build/app/outputs/flutter-apk/`:
   - `movie-imposter.apk` (`arm64-v8a`, ~17.4 MB)
   - `movie-imposter-universal.apk` (Universal FAT, ~47.7 MB)
   - `movie-imposter-armeabi-v7a.apk` (`armeabi-v7a`, ~14.7 MB)
   - `movie-imposter-x86_64.apk` (`x86_64`, ~18.7 MB)

### 6.3 GitHub Release Workflow
When bumping to a new release:
1. Bump version in:
   - `package.json` (`"version": "X.Y.Z"`)
   - `app.json` (`"version": "X.Y.Z"`)
   - `flutter_app/pubspec.yaml` (`version: X.Y.Z+buildNumber`)
   - `flutter_app/lib/services/update_service.dart` (`const String kCurrentAppVersion = 'X.Y.Z';`)
   - `README.md` (badges and download links)
2. Commit and tag:
   ```bash
   git commit -m "docs: update README and bump version to vX.Y.Z"
   git tag -a vX.Y.Z -m "release: vX.Y.Z - Description"
   git push origin main --tags
   ```
3. Publish release via GitHub CLI:
   ```bash
   gh release create vX.Y.Z flutter_app/build/app/outputs/flutter-apk/movie-imposter*.apk --title "Movie Imposter vX.Y.Z" --notes "Release notes..."
   ```

---

## 7. Current Project State (as of Oct 31, 2026)

- **Latest Release**: `v1.4.0` (Live on GitHub).
- **Git Branch**: `main` (clean, fully synced with `origin/main`).
- **Active Games**:
  1. `Movie Imposter` (Party social deduction, 3-10+ players).
  2. `Hangman Battle` (Two-team pass-and-play duel).
- **Test Status**:
  - Flutter: **67/67 tests passing**.
  - Jest: **42/42 tests passing**.
  - TypeScript: **0 compilation errors**.
