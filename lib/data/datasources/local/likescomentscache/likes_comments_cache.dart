import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LikesCommentsCache {
  final String _likesCountKey = 'feedz_likes_count'; // Map<int, int>
  final String _commentsKey = 'feedz_64_comments'; // Map<int, List<String>>

  // --- Likes ---
  Future<Map<int, int>> _getLikesCountMap() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_likesCountKey);
    if (raw == null) return {};
    final map = Map<String, dynamic>.from(json.decode(raw));
    return map.map((k, v) => MapEntry(int.parse(k), v as int));
  }

  Future<int> getLikesCount(int postId) async {
    final likesCountMap = await _getLikesCountMap();
    return likesCountMap[postId] ?? 0;
  }

  Future<void> _setLikesCountMap(Map<int, int> map) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(map.map((k, v) => MapEntry(k.toString(), v)));
    await prefs.setString(_likesCountKey, encoded);
  }

  Future<void> updateLikes(int postId) async {
    final likesCountMap = await _getLikesCountMap();
    final currentLikes = likesCountMap[postId] ?? 0;
    likesCountMap[postId] = currentLikes + 1;
    await _setLikesCountMap(likesCountMap);
  }
  // --- Comments ---

  Future<Map<int, List<String>>> _getCommentsMap() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_commentsKey);
    if (raw == null) return {};
    final decoded = json.decode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) =>
        MapEntry(int.parse(k), List<String>.from(v as List)));
  }

  Future<void> _setCommentsMap(Map<int, List<String>> map) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(
        map.map((k, v) => MapEntry(k.toString(), v))); // List<String> serializes cleanly
    await prefs.setString(_commentsKey, encoded);
  }

  Future<List<String>> getComments(int postId) async {
    final commentsMap = await _getCommentsMap();
    return commentsMap[postId] ?? [];
  }

  Future<void> addComment(int postId, String comment) async {
    final commentsMap = await _getCommentsMap();
    final current = commentsMap[postId] ?? [];
    current.insert(0, comment); // Insert at the beginning for latest-first order
    commentsMap[postId] = current;
    await _setCommentsMap(commentsMap);
  }

  Future<void> deleteComment({required int postId, required int commentIndex})
  async {
    final commentsMap = await _getCommentsMap();
    final currentComments = commentsMap[postId];
    if (currentComments != null &&
        commentIndex >= 0 &&
        commentIndex < currentComments.length) {
      currentComments.removeAt(commentIndex);
      await _setCommentsMap(commentsMap);
    }
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_likesCountKey) ||
          key.startsWith(_commentsKey)) {
        await prefs.remove(key);
      }
    }
  }
}
