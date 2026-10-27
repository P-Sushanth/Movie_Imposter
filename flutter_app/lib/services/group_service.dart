import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_group.dart';

class GroupService {
  static const String kGroupsStorageKey = 'saved_player_groups';
  static const String kSelectedGroupIdKey = 'last_selected_group_id';

  static Future<List<PlayerGroup>> loadGroups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(kGroupsStorageKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map((item) => PlayerGroup.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveGroups(List<PlayerGroup> groups) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(groups.map((g) => g.toJson()).toList());
      await prefs.setString(kGroupsStorageKey, encoded);
    } catch (_) {}
  }

  static Future<PlayerGroup> createGroup({
    required String name,
    required List<String> players,
  }) async {
    final groups = await loadGroups();
    final newGroup = PlayerGroup(
      id: 'grp_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'Group ${groups.length + 1}' : name.trim(),
      players: players.map((p) => p.trim()).toList(),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    groups.add(newGroup);
    await saveGroups(groups);
    await saveLastSelectedGroupId(newGroup.id);
    return newGroup;
  }

  static Future<void> updateGroup(PlayerGroup updatedGroup) async {
    final groups = await loadGroups();
    final index = groups.indexWhere((g) => g.id == updatedGroup.id);
    if (index != -1) {
      groups[index] = updatedGroup;
      await saveGroups(groups);
    }
  }

  static Future<void> renameGroup({
    required String groupId,
    required String newName,
  }) async {
    final groups = await loadGroups();
    final index = groups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      groups[index] = groups[index].copyWith(
        name: newName.trim().isEmpty ? groups[index].name : newName.trim(),
      );
      await saveGroups(groups);
    }
  }

  static Future<void> deleteGroup(String groupId) async {
    final groups = await loadGroups();
    groups.removeWhere((g) => g.id == groupId);
    await saveGroups(groups);

    final lastSelected = await loadLastSelectedGroupId();
    if (lastSelected == groupId) {
      await saveLastSelectedGroupId(null);
    }
  }

  static Future<String?> loadLastSelectedGroupId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(kSelectedGroupIdKey);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveLastSelectedGroupId(String? groupId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (groupId == null) {
        await prefs.remove(kSelectedGroupIdKey);
      } else {
        await prefs.setString(kSelectedGroupIdKey, groupId);
      }
    } catch (_) {}
  }
}
