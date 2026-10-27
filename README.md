# 🎬 Movie Imposter

[![Download Android APK](https://img.shields.io/badge/Download-Android%20APK%20(v1.2.2)-2ea44f?style=for-the-badge&logo=android&logoColor=white)](https://github.com/P-Sushanth/Movie_Imposter/releases/latest/download/movie-imposter.apk)
[![GitHub Release](https://img.shields.io/github/v/release/P-Sushanth/Movie_Imposter?style=for-the-badge&color=blue)](https://github.com/P-Sushanth/Movie_Imposter/releases/latest)
[![Total Downloads](https://img.shields.io/github/downloads/P-Sushanth/Movie_Imposter/total?style=for-the-badge&color=brightgreen)](https://github.com/P-Sushanth/Movie_Imposter/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

An offline, pass-and-play party game inspired by Indian and international cinema (Tollywood, Bollywood, Hollywood), TV/OTT Shows, Korean Dramas (K-Drama), and Nostalgic Cartoons. Designed for 3 or more players (unlimited players!) to enjoy on a single phone with zero internet required.

---

## 📲 Download & Install

1. Download the latest **[movie-imposter.apk (v1.2.2)](https://github.com/P-Sushanth/Movie_Imposter/releases/latest/download/movie-imposter.apk)** directly to your Android device.
2. Tap the downloaded `.apk` file to install (allow *"Install unknown apps"* if prompted).
3. Open **Movie Imposter** and start playing immediately—completely offline with no logins or ads!
4. *All past versions can be found on the [Releases Page](https://github.com/P-Sushanth/Movie_Imposter/releases).*

---

## 🎮 How to Play

1. **Setup**:
   - Choose your categories (**Tollywood**, **Bollywood**, **Hollywood**, **Shows**, **K-Drama**, **Cartoons**, or any combination).
   - Enter player names (3–10+ players).
   - **🔥 Spice It Up**:
     - **Number of Imposters**: Scale up imposters for larger groups.
     - **Give hint to Imposter**: Toggle whether the imposter receives a subtle trivia clue (lead actor, director, genre, channel, country of origin, hint, etc.).
     - **Reveal Name to Imposter**: New modifier where the imposter knows the secret title, turning the game into a battle of pure deduction and deception!

2. **Secret Role Deal**:
   - The device is passed to each player in a **randomized dealing order** so no player is always first.
   - Each player holds their card to secretly reveal either the **Title** or their **Imposter Role**.
   - If "Reveal Name to Imposter" is active, the imposter sees the title highlighted with a flame orange **TITLE** badge.
   - Release the hold before passing the phone to ensure complete privacy.

3. **Discussion & Accusation**:
   - Tap **Start Discussion** to spotlight a **randomly chosen player** to start the round!
   - Players discuss the movie/show/cartoon and ask questions without leaking the title directly.
   - The imposter tries to blend in using their subtle clue or knowledge of the title!
   - Vote on who the imposter is, then tap **Reveal Imposter** to see if the group won.

---

## ✨ Features

- **100% Offline-First**: No servers, no accounts, no analytics, no ads required for gameplay.
- **Multiple Categories**: Play with Tollywood, Bollywood, Hollywood movies, binge-worthy Shows, K-Drama, or nostalgic Cartoons.
- **🔥 Spice It Up Section**: Flame orange configuration hub with multi-imposter support and gameplay modifiers.
- **🎭 Reveal Name to Imposter**: Optional modifier where the imposter knows the title, creating high-stakes psychological bluffing.
- **✂️ Streamlined Trivia Clues**: Clues focus purely on iconic features (cast, directors, channels, genres, trivia hints) with zero giveaway year/decade leaks.
- **🎲 Anti-Repeat Clue Engine**: Ensures the imposter receives diverse, randomized clues without back-to-back repetitions across rounds.
- **Massive Database**: Over 1,100+ curated movies, shows, and cartoons across multiple eras, including recent 2025 and 2026 releases.
- **Session-Based Exclusion**: Played titles are excluded from subsequent rounds so you never get repeats.
- **Randomized Dealing & Starting Player**: Dealing order is shuffled every round, and a random player is spotlighted to start the round.
- **In-App Update Engine**: Automatically notifies you when a new version of the game is available and lets you update with 1 tap.
- **Courier New Retro Typography**: Clean typewriter aesthetic throughout the entire app.
- **Privacy-Safe Card Reveal**: Hold-to-reveal gesture prevents reflection leaks.
- **Dual Framework Architecture**: Available in both high-performance Flutter (native Android APK) and React Native / Expo.

---

## 🛠️ Local Development

### Flutter App (Recommended for Android APK)
```bash
cd flutter_app
flutter pub get
flutter test
flutter run
```

To build the standalone APK:
```bash
# Lightweight APK for modern phones (~16MB, recommended)
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/app/outputs/symbols --android-skip-build-dependency-validation

# Universal APK (~45MB)
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols --android-skip-build-dependency-validation

# Or use automated multi-target build script:
python scripts/build_optimized_apks.py
```

### React Native / Expo App
```bash
npm install
npm test
npm start
```

---
