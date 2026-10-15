# Movie Data and Clue Generation

## 1. Data strategy

Use TMDB as a source for discovering movie metadata, but **do not call TMDB at runtime in the MVP**. Import data during development, review it, and bundle a curated JSON dataset with the app. This keeps gameplay offline and avoids shipping API credentials.

TMDB documentation:
- API overview: https://developer.themoviedb.org/docs/getting-started
- Discover movies: https://developer.themoviedb.org/reference/discover-movie
- Movie details: https://developer.themoviedb.org/reference/movie-details
- Credits: https://developer.themoviedb.org/reference/movie-credits

Check TMDB's current terms, attribution rules, and branding requirements before public distribution. Do not assume all API usage is unrestricted.

## 2. Language filters

TMDB uses ISO-style language codes. Examples:

| Game category | Language code | Caveat |
|---|---|---|
| Tollywood | `te` | Telugu-language filter; may include films not conventionally labelled Tollywood |
| Bollywood | `hi` | Hindi-language filter; Hindi cinema is broader than Bollywood |
| Kollywood | `ta` | Tamil-language filter |
| Mollywood | `ml` | Malayalam-language filter |
| Sandalwood | `kn` | Kannada-language filter |
| Hollywood / International | `en` | English-language films are not all Hollywood productions |

Use explicit `industry` metadata in the bundled dataset for the app's category filtering. Do not infer a perfect industry classification from language alone. For a small MVP dataset, manually review category assignment.

## 3. Recommended schema

Create `src/data/movies.json` with a small, reviewed sample dataset. Use this structure:

```json
[
  {
    "id": "tmdb-123",
    "title": "Example Movie",
    "originalTitle": "Example Movie",
    "originalLanguage": "te",
    "industry": "tollywood",
    "releaseDate": "2022-01-01",
    "genres": ["Action", "Drama"],
    "director": "Example Director",
    "cast": ["Actor One", "Actor Two"],
    "overview": "A short, non-spoiler plot summary.",
    "clueFacts": [
      {
        "type": "genre",
        "text": "It belongs to the action genre."
      },
      {
        "type": "release_decade",
        "text": "It was released in the 2020s."
      },
      {
        "type": "director",
        "text": "It was directed by Example Director."
      }
    ],
    "metadataReviewed": true
  }
]
```

Use a TypeScript union for industry values, for example:
`tollywood | bollywood | kollywood | mollywood | sandalwood | hollywood | other_indian | other_international`.

The sample above is illustrative, not a real record. Do not invent real metadata. For sample entries, use verified metadata or label them clearly as fixtures used only in tests.

## 4. Dataset size

For the first working build, use 20–30 verified movies across at least three categories so the full game flow can be tested. The app must support growing the bundled dataset later to hundreds or thousands of entries.

Do not block the initial app build on collecting hundreds of movies. Add a documented data-import script after the core gameplay works.

## 5. Clue generation

Implement a pure function:

`generateImposterClue(movie, random) -> Clue | null`

Recommended priority:
1. Genre clue, if genre metadata exists.
2. Release decade clue, if release date exists.
3. Director clue, if director metadata exists.
4. Cast clue, if at least one cast member exists.
5. Broad overview clue, if a safe overview exists.

Select randomly among valid clues from a subset of suitable clue types so the same metadata does not always yield the same clue. The clue must not contain the movie title, title fragments, or obvious alternate title. Use a conservative case-insensitive check and skip suspicious clues.

For the MVP, use deterministic templates; do not call a generative AI service. Example templates:
- `It belongs to the {genre} genre.`
- `It was released in the {decade}s.`
- `It was directed by {director}.`
- `One of its cast members is {actor}.`
- `Its story involves: {sanitized short overview}.`

Do not use a plot overview if it contains the title, major spoilers, or an excessively identifying detail. Keep overview clues short. If the app cannot generate a valid clue, select another movie rather than show a blank clue.

## 6. Avoid weak clues

- Do not expose the title through the clue.
- Avoid using only a genre when that genre is too broad? Broad clues are acceptable for the imposter, but the game should choose a valid clue type at random.
- Avoid a cast clue when the actor's name is also the movie title or the name appears in the title.
- Never use exact dialogue, lyrics, screenplay text, or scraped review text.
- Do not download or bundle posters, stills, logos, or other artwork for this MVP.

## 7. Import workflow

Implement a separate developer-only script later in the roadmap:
1. Read a TMDB API key from an environment variable, never from source code.
2. Discover candidate movies by language and filters.
3. Fetch details and credits.
4. Normalize metadata into the local schema.
5. Deduplicate by TMDB ID.
6. Generate candidate clues.
7. Flag incomplete records and suspicious title-revealing clues for review.
8. Write the output JSON.
9. Print TMDB attribution and source information as required by current terms.

The shipped app must consume the generated JSON and must not require a TMDB API key.
