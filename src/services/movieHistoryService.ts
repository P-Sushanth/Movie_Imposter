import AsyncStorage from "@react-native-async-storage/async-storage";

export const USED_MOVIES_STORAGE_KEY = "cached_used_movie_ids";
export const MAX_CACHED_USED_MOVIES = 150;

export const movieHistoryService = {
  /**
   * Load the list of recently used movie IDs from storage.
   */
  async loadUsedMovieIds(): Promise<string[]> {
    try {
      const json = await AsyncStorage.getItem(USED_MOVIES_STORAGE_KEY);
      if (!json) return [];
      const parsed = JSON.parse(json);
      return Array.isArray(parsed) ? parsed : [];
    } catch {
      return [];
    }
  },

  /**
   * Record a movie ID as used. Keeps up to MAX_CACHED_USED_MOVIES most recent entries.
   */
  async recordUsedMovieId(movieId: string): Promise<string[]> {
    try {
      const current = await this.loadUsedMovieIds();
      // Remove any duplicate of this id and append at the end (most recent)
      const filtered = current.filter((id) => id !== movieId);
      filtered.push(movieId);

      // Enforce sliding window cap
      const trimmed = filtered.slice(-MAX_CACHED_USED_MOVIES);
      await AsyncStorage.setItem(USED_MOVIES_STORAGE_KEY, JSON.stringify(trimmed));
      return trimmed;
    } catch {
      return [movieId];
    }
  },

  /**
   * Save the full set/list of used movie IDs (e.g. after pool recycling).
   */
  async saveUsedMovieIds(movieIds: string[]): Promise<void> {
    try {
      const trimmed = movieIds.slice(-MAX_CACHED_USED_MOVIES);
      await AsyncStorage.setItem(USED_MOVIES_STORAGE_KEY, JSON.stringify(trimmed));
    } catch {}
  },

  /**
   * Clear used movies history if ever needed.
   */
  async clearUsedMovies(): Promise<void> {
    try {
      await AsyncStorage.removeItem(USED_MOVIES_STORAGE_KEY);
    } catch {}
  },
};

