# UI / UX Specification

## 1. Visual direction

Create a polished, modern party-game interface with a cinematic feel, but do not imitate a specific film studio or use copyrighted movie artwork.

Design goals:
- Mobile-first and comfortable to use one-handed.
- Strong typography and high contrast.
- Large tap targets.
- Clear separation between setup, private card reveal, and discussion.
- Short labels and minimal text during gameplay.
- Use original gradients, shapes, stars, ticket-like geometry, or abstract film motifs if helpful.
- Do not make the app look like a generic admin dashboard.

Use a consistent spacing scale, typography scale, and color tokens. Support dark mode as the default visual direction; light mode is optional if it can be added without delaying the MVP.

## 2. Screens

### A. Home
- App name: Imposter Who?
- Short one-line explanation.
- Primary CTA: Play
- Optional small note: “Pass the phone. Keep your card secret.”
- No login or onboarding carousel.

### B. Industry selection
- Heading: “Choose your movie universe”
- Selectable chips/cards for Tollywood, Bollywood, Kollywood, Mollywood, Sandalwood, Hollywood / International, and Other Indian Cinema when supported by data.
- Mixed Cinema action that selects all supported categories.
- Allow custom multi-select.
- Clearly indicate selected categories.
- Continue button.

### C. Player setup
- Heading: “Who's playing?”
- Editable player-name rows.
- Add player button, up to 10.
- Remove player control.
- Start with 3 sensible example rows only if they are clearly editable and not silently treated as real players; preferably start with three blank inputs.
- Validate names and duplicates.
- Display “3–10 players” guidance.
- Start Game button.

### D. Card hand-off
- Show current player's name.
- Explain: “Pass the phone to [name]. Only [name] should reveal this card.”
- Card stays hidden until Reveal is tapped.
- Make it obvious whose turn it is.
- Never show another player's role.

### E. Revealed card
- Large central card.
- Normal player: movie title, optionally a small industry label.
- Imposter: label “IMPOSTER” and one clue. Do not show the movie title.
- Button: “Hide card & continue”.
- Add a reminder to memorize the information and hide the card before passing the phone.
- Hide card content when navigating away or app backgrounding where practical.

### F. Discussion
- Heading: “Discussion time”
- Copy: “Everyone has seen their card. Talk it out and find the imposter.”
- No movie title, clue, or role reveal.
- Buttons: New Round, Back to Home.
- If New Round resets the game immediately, label it clearly or show a confirmation.

### G. Empty/error states
- No movies for selected categories: explain the issue and offer Change Categories.
- Invalid player count: state the minimum and maximum.
- Missing metadata: fallback to another clue source rather than showing a blank card.

## 3. Interaction details

- Buttons must show pressed/disabled states.
- Keep a visible progress indicator during dealing, such as “Player 2 of 5”.
- After a card is hidden, the sensitive text must no longer be visible.
- Avoid accidental double taps that advance two players.
- Android system Back must not reveal a card or silently corrupt the round.
- Use safe areas and support small Android screens.
- Respect accessibility font scaling where feasible.
- Provide accessible labels for icon-only controls.

## 4. Copy and tone

Use simple English. The app can add localization later, but the MVP UI should be internally consistent.

Prefer “Imposter” as the role label and “Clue” for the imposter's information. Do not use confusing labels such as “secret movie” for both roles.
