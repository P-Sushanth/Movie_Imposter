import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_imposter/services/group_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loadGroups returns empty list initially', () async {
    final groups = await GroupService.loadGroups();
    expect(groups, isEmpty);
  });

  test('createGroup saves group to storage', () async {
    final created = await GroupService.createGroup(
      name: 'Avengers',
      players: ['Tony', 'Steve', 'Thor'],
    );

    expect(created.name, 'Avengers');
    expect(created.players, ['Tony', 'Steve', 'Thor']);

    final loaded = await GroupService.loadGroups();
    expect(loaded.length, 1);
    expect(loaded.first.id, created.id);
    expect(loaded.first.name, 'Avengers');
    expect(loaded.first.players, ['Tony', 'Steve', 'Thor']);

    final lastSelected = await GroupService.loadLastSelectedGroupId();
    expect(lastSelected, created.id);
  });

  test('renameGroup updates group name', () async {
    final created = await GroupService.createGroup(
      name: 'Initial Name',
      players: ['P1', 'P2', 'P3'],
    );

    await GroupService.renameGroup(
      groupId: created.id,
      newName: 'Updated Name',
    );

    final loaded = await GroupService.loadGroups();
    expect(loaded.first.name, 'Updated Name');
  });

  test('updateGroup modifies player list and order', () async {
    final created = await GroupService.createGroup(
      name: 'Squad',
      players: ['P1', 'P2', 'P3'],
    );

    final modified = created.copyWith(players: ['P3', 'P1', 'P2', 'P4']);
    await GroupService.updateGroup(modified);

    final loaded = await GroupService.loadGroups();
    expect(loaded.first.players, ['P3', 'P1', 'P2', 'P4']);
  });

  test('deleteGroup removes group from storage', () async {
    final created = await GroupService.createGroup(
      name: 'To Delete',
      players: ['A', 'B', 'C'],
    );

    await GroupService.deleteGroup(created.id);

    final loaded = await GroupService.loadGroups();
    expect(loaded, isEmpty);

    final lastSelected = await GroupService.loadLastSelectedGroupId();
    expect(lastSelected, isNull);
  });
}
