# Game Rules and Logic

## 1. Player rules

- Minimum players: 3.
- Maximum players: 10 for the MVP.
- Player names must not be blank after trimming whitespace.
- Names should be unique ignoring letter case. If duplicate names are entered, ask the host to distinguish them or prevent the duplicate.
- Preserve the entry order for display, but shuffle card order at the start of a round if this is straightforward and clearly communicated.

## 2. Round setup

Inputs:
- `players: Player[]`
- `selectedIndustries: Industry[]`
- bundled movie dataset
- optional random seed for tests

Algorithm:
1. Validate at least 3 players.
2. Filter movies to those whose `industry` is in the selected industries.
3. Exclude entries without a usable title or at least one valid clue source.
4. If no movies remain, show a useful error and allow the host to change the category.
5. Select one movie uniformly at random from eligible movies.
6. Select exactly one player uniformly at random as the imposter.
7. Assign the selected movie to every non-imposter.
8. Generate one clue for the imposter from the selected movie's metadata.
9. If a valid clue cannot be generated, try another clue source. If none exists, choose another eligible movie.
10. Store the round state in memory only. Do not persist role assignments to local storage.

Avoid bias in random selection. Use a standard reliable random utility and keep the selection function isolated for testing.

## 3. Card privacy

- Before reveal, a card shows the player's name and a **Reveal card** action.
- On reveal, display either the movie title or the imposter clue.
- Include a prominent **Hide card / Next player** action.
- After hiding, replace the sensitive content immediately.
- Show a hand-off reminder such as: “Pass the phone to the next player. Make sure the previous card is hidden.”
- Do not provide an overview of all player roles.
- Do not put the movie title or clue in notifications, analytics, logs, debug overlays, or persistent storage.
- Prevent accidental exposure through navigation: if the user leaves the reveal screen or the app backgrounds, hide the card when practical.
- Make the revealed content large and readable, without decorative content that makes it hard to conceal.

This is a pass-and-play game, not a security boundary against a player intentionally inspecting the device or app state. The UI should nevertheless avoid accidental disclosure.

## 4. Discussion phase

After all cards have been viewed:
- Show “Everyone has seen their card. Discuss the movie and find the imposter.”
- Do not show the movie title, clue, or imposter identity.
- Provide **New round** and **Home** actions.
- Starting a new round must generate a new assignment. Avoid repeating the same movie consecutively when at least two eligible movies exist.
- Do not implement a scoreboard, vote tracker, or automatic winner detection.

## 5. Clue quality rules

Preferred clue priority:
1. Genre
2. Release decade or year
3. Director
4. Supporting or lead cast member
5. Broad, non-spoiler plot summary

Use one clue per round. Prefer broad clues over clues that directly identify the movie.

Avoid:
- The movie title or its obvious fragments.
- Alternate titles that reveal the answer.
- Exact quotes or lyrics.
- Major spoilers.
- Clues that name every lead actor or give away a uniquely identifying plot detail.
- Empty or malformed metadata.

A clue need not be perfectly cryptic. It should provide the imposter with a reasonable starting point.

## 6. Edge cases

- If fewer than three players are entered, disable Start and explain why.
- If a player name is blank, highlight the field.
- If selected categories have no eligible movies, let the host return to category selection.
- If metadata has no director or cast, use genre/year; do not crash.
- If there is only one eligible movie, allow play but avoid repeating it only when another option exists.
- If a player taps repeatedly, do not skip or corrupt the round.
- If the host starts a new round midway, ask for confirmation or make the reset action clear.
