import AsyncStorage from "@react-native-async-storage/async-storage";
import {
  movieHistoryService,
  MAX_CACHED_USED_MOVIES,
} from "../services/movieHistoryService";

jest.mock("@react-native-async-storage/async-storage", () =>
  require("@react-native-async-storage/async-storage/jest/async-storage-mock")
);

describe("movieHistoryService", () => {
  beforeEach(async () => {
    await AsyncStorage.clear();
  });

  it("returns empty array when no history is stored", async () => {
    const list = await movieHistoryService.loadUsedMovieIds();
    expect(list).toEqual([]);
  });

  it("records used movie IDs and preserves order", async () => {
    await movieHistoryService.recordUsedMovieId("m1");
    await movieHistoryService.recordUsedMovieId("m2");
    await movieHistoryService.recordUsedMovieId("m3");

    const list = await movieHistoryService.loadUsedMovieIds();
    expect(list).toEqual(["m1", "m2", "m3"]);
  });

  it("moves duplicate movie to the end when recorded again", async () => {
    await movieHistoryService.recordUsedMovieId("m1");
    await movieHistoryService.recordUsedMovieId("m2");
    await movieHistoryService.recordUsedMovieId("m1");

    const list = await movieHistoryService.loadUsedMovieIds();
    expect(list).toEqual(["m2", "m1"]);
  });

  it("respects MAX_CACHED_USED_MOVIES limit", async () => {
    const ids: string[] = [];
    for (let i = 0; i < MAX_CACHED_USED_MOVIES + 20; i++) {
      ids.push(`movie_${i}`);
    }
    await movieHistoryService.saveUsedMovieIds(ids);

    const loaded = await movieHistoryService.loadUsedMovieIds();
    expect(loaded.length).toBe(MAX_CACHED_USED_MOVIES);
    expect(loaded[0]).toBe(`movie_20`);
    expect(loaded[loaded.length - 1]).toBe(`movie_${MAX_CACHED_USED_MOVIES + 19}`);
  });

  it("clears used movies history", async () => {
    await movieHistoryService.recordUsedMovieId("m1");
    await movieHistoryService.clearUsedMovies();
    const list = await movieHistoryService.loadUsedMovieIds();
    expect(list).toEqual([]);
  });
});
