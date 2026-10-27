import { groupService } from "../services/groupService";
import AsyncStorage from "@react-native-async-storage/async-storage";

jest.mock("@react-native-async-storage/async-storage", () =>
  require("@react-native-async-storage/async-storage/jest/async-storage-mock")
);

describe("groupService", () => {
  beforeEach(async () => {
    await AsyncStorage.clear();
  });

  test("loadGroups returns empty array when nothing is stored", async () => {
    const groups = await groupService.loadGroups();
    expect(groups).toEqual([]);
  });

  test("createGroup saves and returns new group", async () => {
    const created = await groupService.createGroup("Movie Buffs", ["Alice", "Bob", "Charlie"]);
    expect(created.name).toBe("Movie Buffs");
    expect(created.players).toEqual(["Alice", "Bob", "Charlie"]);

    const loaded = await groupService.loadGroups();
    expect(loaded).toHaveLength(1);
    expect(loaded[0].name).toBe("Movie Buffs");

    const lastSelected = await groupService.loadLastSelectedGroupId();
    expect(lastSelected).toBe(created.id);
  });

  test("renameGroup updates group name", async () => {
    const created = await groupService.createGroup("Old Name", ["A", "B", "C"]);
    await groupService.renameGroup(created.id, "New Name");

    const loaded = await groupService.loadGroups();
    expect(loaded[0].name).toBe("New Name");
  });

  test("updateGroup updates player list", async () => {
    const created = await groupService.createGroup("Squad", ["A", "B", "C"]);
    await groupService.updateGroup({ ...created, players: ["C", "B", "A", "D"] });

    const loaded = await groupService.loadGroups();
    expect(loaded[0].players).toEqual(["C", "B", "A", "D"]);
  });

  test("deleteGroup removes group and clears last selected if matched", async () => {
    const created = await groupService.createGroup("To Delete", ["A", "B", "C"]);
    await groupService.deleteGroup(created.id);

    const loaded = await groupService.loadGroups();
    expect(loaded).toHaveLength(0);

    const lastSelected = await groupService.loadLastSelectedGroupId();
    expect(lastSelected).toBeNull();
  });
});
