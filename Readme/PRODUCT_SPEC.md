# Product Specification

## 1. Product

**Name:** Imposter Who?  
**Product type:** Local pass-and-play party game  
**Audience:** Fans of Indian cinema and international movies  
**Primary platform:** Android  
**Connectivity:** Offline during gameplay

## 2. Core concept

A group shares one phone. Each player privately reveals a card. Most players see the same movie title; one randomly selected imposter sees a clue about that movie instead. Players then discuss the movie and try to identify the imposter.

The app facilitates a round; it does not need to score or judge the discussion.

## 3. MVP goals

- Start a round quickly with 3–10 players.
- Let players choose one or more cinema categories.
- Assign exactly one imposter by default.
- Keep each player's role hidden from other players.
- Provide the imposter with a useful but not overly revealing clue.
- Work without a network connection.
- Make starting another round straightforward.

## 4. Supported categories

Use these user-facing labels:

- Tollywood — Telugu-language cinema
- Bollywood — Hindi-language cinema
- Kollywood — Tamil-language cinema
- Mollywood — Malayalam-language cinema
- Sandalwood — Kannada-language cinema
- Hollywood / International — English-language and selected international films, if present in the local dataset
- Other Indian Cinema — other Indian-language films, when the dataset supports them
- Mixed Cinema — movies from all selected categories

Important: these are practical game categories, not perfectly precise industry classifications. The dataset must carry an explicit `industry` value separate from `originalLanguage`.

## 5. Main user journey

1. Open the app.
2. Tap **Play**.
3. Select one or more industries, or choose **Mixed Cinema**.
4. Add 3–10 player names.
5. Start the round.
6. The app selects a movie and one imposter.
7. Players take turns opening the device and revealing their own cards.
8. Each player reads their card privately and hides it.
9. After all players have seen their cards, the app displays a **Discussion time** screen.
10. Players discuss and decide who the imposter is outside the app.
11. The host may start a new round.

Do not reveal the answer or expose the full role list on the discussion screen. In the MVP, players can discuss and vote verbally; there is no in-app voting or result reveal.

## 6. MVP features

### Required
- Home screen
- Industry selection
- Player-name entry and validation
- Start round
- Random movie selection from selected industries
- Exactly one imposter
- Movie title card for normal players
- Clue card for the imposter
- Reveal / hide card interaction
- Clear hand-off instruction between players
- Discussion screen
- New round and return-to-home actions
- Offline bundled dataset
- Empty-data and insufficient-player handling

### Explicitly not in MVP
- Scoreboard or persistent stats
- User accounts
- Online multiplayer or room codes
- Chat or in-app voting
- Multiple imposters
- Custom difficulty settings
- User-generated movie submissions
- Live TMDB API requests
- AI API calls
- Ads, payments, or subscriptions
- Downloadable movie packs
- Other mini-games (trivia, emoji guessing, dialogue guessing, etc.)

## 7. Success criteria

A new group can start and complete a round without instructions from the developer. The app works in airplane mode, no player sees all roles at once, and a new round can be started without restarting the app.
