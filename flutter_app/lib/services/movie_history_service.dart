import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MovieHistoryService {
  static const String kUsedMoviesStorageKey = 'cached_used_movie_ids';
  static const int kMaxCachedUsedMovies = 150;

  /// Load the list of recently used movie IDs from local cache.
  static Future<List<String>> loadUsedMovieIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(kUsedMoviesStorageKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  /// Record a movie ID as used. Maintains a sliding window up to kMaxCachedUsedMovies.
  static Future<List<String>> recordUsedMovieId(String movieId) async {
    try {
      final current = await loadUsedMovieIds();
      // Remove previous occurrence if any, append to end
      final filtered = current.where((id) => id != movieId).toList();
      filtered.add(movieId);

      // Enforce sliding window limit
      final trimmed = filtered.length > kMaxCachedUsedMovies
          ? filtered.sublist(filtered.length - kMaxCachedUsedMovies)
          : filtered;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kUsedMoviesStorageKey, jsonEncode(trimmed));
      return trimmed;
    } catch (_) {
      return [movieId];
    }
  }

  /// Save the full list of used movie IDs (e.g. after pool recycling).
  static Future<void> saveUsedMovieIds(List<String> movieIds) async {
    try {
      final trimmed = movieIds.length > kMaxCachedUsedMovies
          ? movieIds.sublist(movieIds.length - kMaxCachedUsedMovies)
          : movieIds;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kUsedMoviesStorageKey, jsonEncode(trimmed));
    } catch (_) {}
  }

  /// Clear used movies cache.
  static Future<void> clearUsedMovies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(kUsedMoviesStorageKey);
    } catch (_) {}
  }
}

