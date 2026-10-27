import AsyncStorage from "@react-native-async-storage/async-storage";
import { PlayerGroup } from "../domain/types";

const GROUPS_STORAGE_KEY = "saved_player_groups";
const SELECTED_GROUP_ID_KEY = "last_selected_group_id";

export const groupService = {
  async loadGroups(): Promise<PlayerGroup[]> {
    try {
      const json = await AsyncStorage.getItem(GROUPS_STORAGE_KEY);
      if (!json) return [];
      return JSON.parse(json) as PlayerGroup[];
    } catch {
      return [];
    }
  },

  async saveGroups(groups: PlayerGroup[]): Promise<void> {
    try {
      await AsyncStorage.setItem(GROUPS_STORAGE_KEY, JSON.stringify(groups));
    } catch {}
  },

  async createGroup(name: string, players: string[]): Promise<PlayerGroup> {
    const groups = await this.loadGroups();
    const newGroup: PlayerGroup = {
      id: `grp_${Date.now()}`,
      name: name.trim() || `Group ${groups.length + 1}`,
      players: players.map((p) => p.trim()),
      createdAt: Date.now(),
    };
    groups.push(newGroup);
    await this.saveGroups(groups);
    await this.saveLastSelectedGroupId(newGroup.id);
    return newGroup;
  },

  async renameGroup(groupId: string, newName: string): Promise<void> {
    const groups = await this.loadGroups();
    const group = groups.find((g) => g.id === groupId);
    if (group) {
      group.name = newName.trim() || group.name;
      await this.saveGroups(groups);
    }
  },

  async updateGroup(updatedGroup: PlayerGroup): Promise<void> {
    const groups = await this.loadGroups();
    const index = groups.findIndex((g) => g.id === updatedGroup.id);
    if (index !== -1) {
      groups[index] = updatedGroup;
      await this.saveGroups(groups);
    }
  },

  async deleteGroup(groupId: string): Promise<void> {
    const groups = await this.loadGroups();
    const filtered = groups.filter((g) => g.id !== groupId);
    await this.saveGroups(filtered);

    const lastSelected = await this.loadLastSelectedGroupId();
    if (lastSelected === groupId) {
      await this.saveLastSelectedGroupId(null);
    }
  },

  async loadLastSelectedGroupId(): Promise<string | null> {
    try {
      return await AsyncStorage.getItem(SELECTED_GROUP_ID_KEY);
    } catch {
      return null;
    }
  },

  async saveLastSelectedGroupId(groupId: string | null): Promise<void> {
    try {
      if (groupId === null) {
        await AsyncStorage.removeItem(SELECTED_GROUP_ID_KEY);
      } else {
        await AsyncStorage.setItem(SELECTED_GROUP_ID_KEY, groupId);
      }
    } catch {}
  },
};
