# 🎬 Movie Imposter

[![Download Android APK](https://img.shields.io/badge/Download-Android%20APK%20(v1.1.1)-2ea44f?style=for-the-badge&logo=android&logoColor=white)](https://github.com/P-Sushanth/Movie_Imposter/releases/latest/download/movie-imposter.apk)
[![GitHub Release](https://img.shields.io/github/v/release/P-Sushanth/Movie_Imposter?style=for-the-badge&color=blue)](https://github.com/P-Sushanth/Movie_Imposter/releases/latest)
[![Total Downloads](https://img.shields.io/github/downloads/P-Sushanth/Movie_Imposter/total?style=for-the-badge&color=brightgreen)](https://github.com/P-Sushanth/Movie_Imposter/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

An offline, pass-and-play party game inspired by Indian and international cinema (Tollywood, Bollywood, Hollywood) and popular TV/OTT Shows. Designed for 3 or more players (unlimited players!) to enjoy on a single phone with zero internet required.

---

## 📲 Download & Install

1. Download the latest **[movie-imposter.apk (v1.1.1)](https://github.com/P-Sushanth/Movie_Imposter/releases/latest/download/movie-imposter.apk)** directly to your Android device.
2. Tap the downloaded `.apk` file to install (allow *"Install unknown apps"* if prompted).
3. Open **Movie Imposter** and start playing immediately—completely offline with no logins or ads!
4. *All past versions can be found on the [Releases Page](https://github.com/P-Sushanth/Movie_Imposter/releases).*

---

## 🎮 How to Play

1. **Setup**:
   - Choose your categories (**Tollywood**, **Bollywood**, **Hollywood**, **Shows**, or any combination).
   - Enter player names (3–10+ players) and set the number of imposters.
   - Choose whether the imposter receives a subtle clue (decade, channel/platform, director, genre, etc.).

2. **Secret Role Deal**:
   - The device is passed to each player in a **randomized dealing order** so no player is always first.
   - Each player holds their card to secretly reveal either the **Title** or the **Imposter Role**.
   - Release the hold before passing the phone to ensure complete privacy.

3. **Discussion & Accusation**:
   - Tap **Start Discussion** to spotlight a **randomly chosen player** to start the round!
   - Players discuss the movie/show and ask questions without leaking the title directly.
   - The imposter tries to blend in using their subtle clue!
   - Vote on who the imposter is, then tap **Reveal Imposter** to see if the group won.

---

## ✨ Features

- **100% Offline-First**: No servers, no accounts, no analytics, no ads required for gameplay.
- **Multiple Categories**: Play with Tollywood, Bollywood, Hollywood movies, or binge-worthy Indian & global Shows.
- **Massive Database**: Over 1,100+ curated movies and shows across multiple decades, including recent 2025 and 2026 releases.
- **Session-Based Exclusion**: Played titles are excluded from subsequent rounds so you never get repeats.
- **Randomized Dealing & Starting Player**: Dealing order is shuffled every round, and a random player is spotlighted to start the round.
- **In-App Update Engine**: Automatically notifies you when a new version of the game is available and lets you update with 1 tap.
- **Courier New Retro Typography**: Clean typewriter aesthetic throughout the entire app.
- **Privacy-Safe Card Reveal**: Hold-to-reveal gesture prevents reflection leaks.
- **Tailored Clues**: Custom clue generators for movies and shows that give the imposter a fighting chance without giving away the title.
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

To build a new standalone APK:
```bash
flutter build apk --release --android-skip-build-dependency-validation
```

### React Native / Expo App
```bash
npm install
npm test
npm start
```

---
