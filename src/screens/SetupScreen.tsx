import React, { useState } from "react";
import {
  View,
  Text,
  TextInput,
  StyleSheet,
  ScrollView,
  Pressable,
  Switch,
  Modal,
  Alert,
} from "react-native";
import { colors, spacing, typography, borderRadius, courierFont } from "../theme";
import { Industry } from "../data/movies/types";
import { PlayerGroup } from "../domain/types";
import { resolvePlayerNames } from "../domain/validation";
import { PrimaryButton } from "../components/PrimaryButton";

interface SetupScreenProps {
  selectedIndustries: Industry[];
  onToggleIndustry: (industry: Industry) => void;
  onSelectAllIndustries: () => void;
  players: string[];
  onChangePlayer: (index: number, name: string) => void;
  onAddPlayer: () => void;
  onRemovePlayer: (index: number) => void;
  onMovePlayer: (fromIndex: number, toIndex: number) => void;
  savedGroups?: PlayerGroup[];
  selectedGroupId?: string | null;
  onSelectGroup?: (group: PlayerGroup) => void;
  onCreateGroup?: (name: string) => void;
  onRenameGroup?: (groupId: string, newName: string) => void;
  onUpdateGroup?: (group: PlayerGroup) => void;
  onDeleteGroup?: (groupId: string) => void;
  onClearGroup?: () => void;
  numImposters: number;
  onChangeNumImposters: (count: number) => void;
  imposterClueEnabled: boolean;
  onToggleClueEnabled: (enabled: boolean) => void;
  revealNameToImposter: boolean;
  onToggleRevealNameToImposter: (enabled: boolean) => void;
  discussionTimerMinutes: number;
  onChangeDiscussionTimer: (minutes: number) => void;
  onStartGame: () => void;
  onBackToHub?: () => void;
}

const CATEGORIES: { id: Industry; label: string }[] = [
  { id: "tollywood", label: "Tollywood" },
  { id: "bollywood", label: "Bollywood" },
  { id: "hollywood", label: "Hollywood" },
];

export const SetupScreen: React.FC<SetupScreenProps> = ({
  selectedIndustries,
  onToggleIndustry,
  onSelectAllIndustries,
  players,
  onChangePlayer,
  onAddPlayer,
  onRemovePlayer,
  onMovePlayer,
  savedGroups = [],
  selectedGroupId,
  onSelectGroup,
  onCreateGroup,
  onRenameGroup,
  onUpdateGroup,
  onDeleteGroup,
  onClearGroup,
  numImposters,
  onChangeNumImposters,
  imposterClueEnabled,
  onToggleClueEnabled,
  revealNameToImposter,
  onToggleRevealNameToImposter,
  discussionTimerMinutes = 0,
  onChangeDiscussionTimer,
  onStartGame,
  onBackToHub,
}) => {
  const maxImposters = Math.max(1, Math.floor(players.length / 2));
  const canAddMorePlayers = players.length < 10;
  const canRemovePlayer = players.length > 3;

  // Group modal state
  const [saveModalVisible, setSaveModalVisible] = useState(false);
  const [groupNameToSave, setGroupNameToSave] = useState("");
  const [renameModalVisible, setRenameModalVisible] = useState(false);
  const [groupNameToRename, setGroupNameToRename] = useState("");
  const [groupToRename, setGroupToRename] = useState<PlayerGroup | null>(null);
  const [deleteModalVisible, setDeleteModalVisible] = useState(false);
  const [groupToDelete, setGroupToDelete] = useState<PlayerGroup | null>(null);

  const handleOpenSaveModal = () => {
    const valid = resolvePlayerNames(players);
    if (valid.length < 3) {
      Alert.alert("Cannot Save Group", "Please have at least 3 players before saving a group.");
      return;
    }
    setGroupNameToSave(`Group ${savedGroups.length + 1}`);
    setSaveModalVisible(true);
  };

  const handleConfirmSave = () => {
    const name = groupNameToSave.trim();
    if (name) {
      onCreateGroup?.(name);
      setSaveModalVisible(false);
    }
  };

  const handleOpenRenameModal = (group: PlayerGroup) => {
    setGroupToRename(group);
    setGroupNameToRename(group.name);
    setRenameModalVisible(true);
  };

  const handleConfirmRename = () => {
    const name = groupNameToRename.trim();
    if (name && groupToRename) {
      onRenameGroup?.(groupToRename.id, name);
      setRenameModalVisible(false);
    }
  };

  const handleConfirmDelete = (group: PlayerGroup) => {
    setGroupToDelete(group);
    setDeleteModalVisible(true);
  };

  const selectedGroup = savedGroups.find((g) => g.id === selectedGroupId);

  const handleDecrementImposters = () => {
    if (numImposters > 1) {
      onChangeNumImposters(numImposters - 1);
    }
  };

  const handleIncrementImposters = () => {
    if (numImposters < maxImposters) {
      onChangeNumImposters(numImposters + 1);
    }
  };

  const handleDecrementTimer = () => {
    if (discussionTimerMinutes > 0) {
      onChangeDiscussionTimer(discussionTimerMinutes - 1);
    }
  };

  const handleIncrementTimer = () => {
    if (discussionTimerMinutes < 10) {
      onChangeDiscussionTimer(discussionTimerMinutes + 1);
    }
  };

  return (
    <View style={styles.container}>
      <ScrollView
        style={styles.scrollArea}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
        keyboardShouldPersistTaps="handled"
      >
        {/* App Title */}
        <View style={styles.header}>
          <View style={{ flexDirection: "row", alignItems: "center" }}>
            {onBackToHub ? (
              <Pressable
                onPress={onBackToHub}
                style={{
                  width: 34,
                  height: 34,
                  borderRadius: 8,
                  backgroundColor: colors.surfaceElevated,
                  borderWidth: 1,
                  borderColor: colors.surfaceBorder,
                  justifyContent: "center",
                  alignItems: "center",
                  marginRight: 10,
                }}
              >
                <Text style={{ fontSize: 16, fontWeight: "700", color: colors.textPrimary }}>←</Text>
              </Pressable>
            ) : null}
            <Text style={styles.title}>Movie Imposter</Text>
          </View>
        </View>

        {/* 1. Categories Section */}
        <View style={styles.section}>
          <View style={styles.sectionHeaderRow}>
            <Text style={styles.sectionTitle}>Categories</Text>
            <Pressable onPress={onSelectAllIndustries} hitSlop={8}>
              <Text style={styles.selectAllText}>Select All</Text>
            </Pressable>
          </View>
          <View style={styles.categoryRow}>
            {CATEGORIES.map((cat) => {
              const isSelected = selectedIndustries.includes(cat.id);
              return (
                <Pressable
                  key={cat.id}
                  onPress={() => onToggleIndustry(cat.id)}
                  style={[
                    styles.categoryChip,
                    isSelected && styles.categoryChipSelected,
                  ]}
                  accessibilityRole="checkbox"
                  accessibilityState={{ checked: isSelected }}
                >
                  <Text
                    style={[
                      styles.categoryChipText,
                      isSelected && styles.categoryChipTextSelected,
                    ]}
                  >
                    {cat.label}
                  </Text>
                </Pressable>
              );
            })}
          </View>
        </View>

        {/* 2. Spice It Up Section (Flame Orange) */}
        <View style={styles.spicedSection}>
          <View style={styles.spicedHeaderRow}>
            <Text style={styles.spicedHeaderTitle}>🔥 Spice It Up</Text>
          </View>

          <View style={styles.spicedDivider} />

          {/* Option 1: Number of Imposters */}
          <View style={styles.spicedOptionRow}>
            <View style={styles.switchTextContainer}>
              <Text style={styles.sectionTitle}>Number of Imposters</Text>
              <Text style={styles.sectionSubtitle}>
                Max {maxImposters} for {players.length} players
              </Text>
            </View>
            <View style={styles.stepperContainer}>
              <Pressable
                onPress={handleDecrementImposters}
                disabled={numImposters <= 1}
                style={[
                  styles.stepperButton,
                  numImposters <= 1 && styles.stepperButtonDisabled,
                ]}
                hitSlop={8}
              >
                <Text
                  style={[
                    styles.stepperButtonText,
                    numImposters <= 1 && styles.stepperButtonTextDisabled,
                  ]}
                >
                  −
                </Text>
              </Pressable>

              <View style={styles.stepperValueContainer}>
                <Text style={[styles.stepperValueText, { color: "#D84315" }]}>
                  {numImposters}
                </Text>
              </View>

              <Pressable
                onPress={handleIncrementImposters}
                disabled={numImposters >= maxImposters}
                style={[
                  styles.stepperButton,
                  numImposters >= maxImposters && styles.stepperButtonDisabled,
                ]}
                hitSlop={8}
              >
                <Text
                  style={[
                    styles.stepperButtonText,
                    numImposters >= maxImposters && styles.stepperButtonTextDisabled,
                  ]}
                >
                  +
                </Text>
              </Pressable>
            </View>
          </View>

          <View style={styles.spicedDivider} />

          {/* Option 2: Discussion Timer */}
          <View style={styles.spicedOptionRow}>
            <View style={styles.switchTextContainer}>
              <Text style={styles.sectionTitle}>Discussion Timer</Text>
              <Text style={styles.sectionSubtitle}>
                {discussionTimerMinutes === 0
                  ? "0 min (No Limit)"
                  : `${discussionTimerMinutes} min${discussionTimerMinutes > 1 ? "s" : ""} countdown`}
              </Text>
            </View>
            <View style={styles.stepperContainer}>
              <Pressable
                onPress={handleDecrementTimer}
                disabled={discussionTimerMinutes <= 0}
                style={[
                  styles.stepperButton,
                  discussionTimerMinutes <= 0 && styles.stepperButtonDisabled,
                ]}
                hitSlop={8}
              >
                <Text
                  style={[
                    styles.stepperButtonText,
                    discussionTimerMinutes <= 0 && styles.stepperButtonTextDisabled,
                  ]}
                >
                  −
                </Text>
              </Pressable>

              <View style={styles.stepperValueContainer}>
                <Text style={[styles.stepperValueText, { color: "#D84315" }]}>
                  {discussionTimerMinutes}
                </Text>
              </View>

              <Pressable
                onPress={handleIncrementTimer}
                disabled={discussionTimerMinutes >= 10}
                style={[
                  styles.stepperButton,
                  discussionTimerMinutes >= 10 && styles.stepperButtonDisabled,
                ]}
                hitSlop={8}
              >
                <Text
                  style={[
                    styles.stepperButtonText,
                    discussionTimerMinutes >= 10 && styles.stepperButtonTextDisabled,
                  ]}
                >
                  +
                </Text>
              </Pressable>
            </View>
          </View>

          <View style={styles.spicedDivider} />

          {/* Option 3: Give hint to imposter */}
          <View style={styles.switchRow}>
            <View style={styles.switchTextContainer}>
              <Text style={styles.sectionTitle}>Give hint to imposter</Text>
            </View>
            <Switch
              value={imposterClueEnabled}
              onValueChange={onToggleClueEnabled}
              trackColor={{ false: "#CBD5E1", true: "#FF5722" }}
              thumbColor={colors.surface}
            />
          </View>

          <View style={styles.spicedDivider} />

          {/* Option 3: Reveal Name to Imposter */}
          <View style={styles.switchRow}>
            <View style={styles.switchTextContainer}>
              <Text style={styles.sectionTitle}>Reveal Name to Imposter</Text>
            </View>
            <Switch
              value={revealNameToImposter}
              onValueChange={onToggleRevealNameToImposter}
              trackColor={{ false: "#CBD5E1", true: "#FF5722" }}
              thumbColor={colors.surface}
            />
          </View>
        </View>

        {/* 4. Players Section */}
        <View style={styles.section}>
          <View style={styles.sectionHeaderRow}>
            <Text style={styles.sectionTitle}>Players ({players.length})</Text>
            <Pressable
              onPress={handleOpenSaveModal}
              style={styles.saveGroupBtn}
              hitSlop={8}
            >
              <Text style={styles.saveGroupBtnText}>💾 Save as Group</Text>
            </Pressable>
          </View>

          {/* Saved Groups Chips */}
          {savedGroups.length > 0 && (
            <ScrollView
              horizontal
              showsHorizontalScrollIndicator={false}
              contentContainerStyle={styles.groupChipsContainer}
            >
              {savedGroups.map((group) => {
                const isSelected = selectedGroupId === group.id;
                return (
                  <Pressable
                    key={group.id}
                    onPress={() => {
                      if (isSelected) {
                        onClearGroup?.();
                      } else {
                        onSelectGroup?.(group);
                      }
                    }}
                    style={[
                      styles.groupChip,
                      isSelected && styles.groupChipSelected,
                    ]}
                  >
                    <Text
                      style={[
                        styles.groupChipText,
                        isSelected && styles.groupChipTextSelected,
                      ]}
                    >
                      {group.name} ({group.players.length})
                    </Text>
                  </Pressable>
                );
              })}
            </ScrollView>
          )}

          {/* Active Group Banner */}
          {selectedGroup && (
            <View style={styles.activeGroupBanner}>
              <Text style={styles.activeGroupText} numberOfLines={1}>
                Group: {selectedGroup.name}
              </Text>
              <View style={styles.activeGroupActions}>
                <Pressable
                  onPress={() => handleOpenRenameModal(selectedGroup)}
                  style={styles.groupActionBtn}
                  hitSlop={6}
                >
                  <Text style={styles.groupActionBtnText}>✎</Text>
                </Pressable>
                <Pressable
                  onPress={() => {
                    const valid = players.map((p) => p.trim());
                    onUpdateGroup?.({ ...selectedGroup, players: valid });
                    Alert.alert("Group Updated", `Saved current players to "${selectedGroup.name}".`);
                  }}
                  style={styles.groupActionBtn}
                  hitSlop={6}
                >
                  <Text style={styles.groupActionBtnText}>💾</Text>
                </Pressable>
                <Pressable
                  onPress={() => handleConfirmDelete(selectedGroup)}
                  style={styles.groupActionBtn}
                  hitSlop={6}
                >
                  <Text style={[styles.groupActionBtnText, { color: colors.danger }]}>✕</Text>
                </Pressable>
              </View>
            </View>
          )}

          {players.map((name, index) => (
            <View key={index} style={styles.playerInputRow}>
              <View style={styles.playerNumberBadge}>
                <Text style={styles.playerNumberText}>{index + 1}</Text>
              </View>
              <TextInput
                style={styles.playerInput}
                value={name}
                onChangeText={(text) => onChangePlayer(index, text)}
                placeholder={`Player ${index + 1}`}
                placeholderTextColor={colors.textMuted}
                maxLength={20}
                autoCorrect={false}
              />
              <Pressable
                onPress={() => onMovePlayer(index, (index + 1) % players.length)}
                style={styles.movePlayerBtn}
                hitSlop={6}
                accessibilityLabel={`Reorder player ${index + 1}`}
              >
                <Text style={styles.movePlayerText}>↕</Text>
              </Pressable>
              {canRemovePlayer && (
                <Pressable
                  onPress={() => onRemovePlayer(index)}
                  style={styles.removePlayerBtn}
                  hitSlop={10}
                >
                  <Text style={styles.removePlayerText}>✕</Text>
                </Pressable>
              )}
            </View>
          ))}

          {canAddMorePlayers && (
            <Pressable onPress={onAddPlayer} style={styles.addPlayerBtn}>
              <Text style={styles.addPlayerBtnText}>+ Add Player</Text>
            </Pressable>
          )}
        </View>
      </ScrollView>

      {/* Start Game Action */}
      <View style={styles.footer}>
        <PrimaryButton
          title="Start Game"
          onPress={onStartGame}
          disabled={selectedIndustries.length === 0}
          style={styles.startButton}
        />
      </View>

      {/* Save Group Modal */}
      <Modal
        visible={saveModalVisible}
        transparent
        animationType="fade"
        onRequestClose={() => setSaveModalVisible(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalCard}>
            <Text style={styles.modalTitle}>Save as Group</Text>
            <Text style={styles.modalSubtitle}>Enter a name for this group of players:</Text>
            <TextInput
              style={styles.modalInput}
              value={groupNameToSave}
              onChangeText={setGroupNameToSave}
              placeholder="e.g. Movie Squad"
              placeholderTextColor={colors.textMuted}
              maxLength={24}
              autoFocus
            />
            <View style={styles.modalActions}>
              <Pressable
                onPress={() => setSaveModalVisible(false)}
                style={styles.modalCancelBtn}
              >
                <Text style={styles.modalCancelText}>Cancel</Text>
              </Pressable>
              <Pressable
                onPress={handleConfirmSave}
                style={styles.modalConfirmBtn}
              >
                <Text style={styles.modalConfirmText}>Save Group</Text>
              </Pressable>
            </View>
          </View>
        </View>
      </Modal>

      {/* Rename Group Modal */}
      <Modal
        visible={renameModalVisible}
        transparent
        animationType="fade"
        onRequestClose={() => setRenameModalVisible(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalCard}>
            <Text style={styles.modalTitle}>Rename Group</Text>
            <TextInput
              style={styles.modalInput}
              value={groupNameToRename}
              onChangeText={setGroupNameToRename}
              placeholder="Group Name"
              placeholderTextColor={colors.textMuted}
              maxLength={24}
              autoFocus
            />
            <View style={styles.modalActions}>
              <Pressable
                onPress={() => setRenameModalVisible(false)}
                style={styles.modalCancelBtn}
              >
                <Text style={styles.modalCancelText}>Cancel</Text>
              </Pressable>
              <Pressable
                onPress={handleConfirmRename}
                style={styles.modalConfirmBtn}
              >
                <Text style={styles.modalConfirmText}>Save</Text>
              </Pressable>
            </View>
          </View>
        </View>
      </Modal>

      {/* Delete Group Modal */}
      <Modal
        visible={deleteModalVisible}
        transparent
        animationType="fade"
        onRequestClose={() => setDeleteModalVisible(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalCard}>
            <View style={styles.modalHeaderRow}>
              <View style={styles.modalDangerIconBadge}>
                <Text style={styles.modalDangerIconText}>🗑️</Text>
              </View>
              <Text style={styles.modalTitle}>Delete "{groupToDelete?.name}"?</Text>
            </View>
            <Text style={styles.modalSubtitle}>
              This group will be removed from your saved groups.
            </Text>
            <View style={styles.modalActions}>
              <Pressable
                onPress={() => setDeleteModalVisible(false)}
                style={styles.modalCancelBtn}
              >
                <Text style={styles.modalCancelText}>Cancel</Text>
              </Pressable>
              <Pressable
                onPress={() => {
                  if (groupToDelete) {
                    onDeleteGroup?.(groupToDelete.id);
                    setDeleteModalVisible(false);
                  }
                }}
                style={styles.modalDeleteConfirmBtn}
              >
                <Text style={styles.modalDeleteConfirmText}>Delete</Text>
              </Pressable>
            </View>
          </View>
        </View>
      </Modal>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  scrollArea: {
    flex: 1,
  },
  scrollContent: {
    paddingHorizontal: spacing.lg,
    paddingTop: spacing.lg,
    paddingBottom: spacing.xl,
  },
  header: {
    marginBottom: spacing.lg,
  },
  title: {
    ...typography.h1,
    fontSize: 28,
    color: colors.textPrimary,
  },
  section: {
    backgroundColor: colors.surface,
    borderColor: colors.surfaceBorder,
    borderWidth: 1,
    borderRadius: borderRadius.lg,
    padding: spacing.lg,
    marginBottom: spacing.lg,
  },
  spicedSection: {
    backgroundColor: "#FFF7F2",
    borderColor: "#FF5722",
    borderWidth: 2,
    borderRadius: borderRadius.lg,
    padding: spacing.lg,
    marginBottom: spacing.lg,
  },
  spicedHeaderRow: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
  },
  spicedHeaderTitle: {
    fontFamily: courierFont,
    fontSize: 18,
    fontWeight: "800",
    color: "#D84315",
    letterSpacing: -0.3,
  },
  spicedBadge: {
    backgroundColor: "rgba(255, 87, 34, 0.15)",
    borderColor: "rgba(255, 87, 34, 0.4)",
    borderWidth: 1,
    borderRadius: 100,
    paddingHorizontal: 8,
    paddingVertical: 3,
  },
  spicedBadgeText: {
    fontFamily: courierFont,
    fontSize: 10,
    fontWeight: "800",
    color: "#D84315",
    letterSpacing: 0.8,
  },
  spicedDivider: {
    height: 1,
    backgroundColor: "#FFD0B8",
    marginVertical: spacing.md,
  },
  spicedOptionRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
  },
  sectionHeaderRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: spacing.md,
  },
  sectionTitle: {
    ...typography.h3,
    fontSize: 16,
    color: colors.textPrimary,
  },
  sectionSubtitle: {
    ...typography.bodySmall,
    color: colors.textSecondary,
    marginTop: 2,
  },
  sectionSubtitleInline: {
    ...typography.caption,
    color: colors.textMuted,
    textTransform: "none",
  },
  selectAllText: {
    ...typography.bodySmall,
    color: colors.primary,
    fontWeight: "600",
  },
  categoryRow: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: spacing.sm,
  },
  categoryChip: {
    backgroundColor: colors.surfaceElevated,
    borderColor: colors.surfaceBorder,
    borderWidth: 1,
    borderRadius: borderRadius.md,
    paddingVertical: spacing.sm,
    paddingHorizontal: spacing.lg,
  },
  categoryChipSelected: {
    backgroundColor: colors.primary,
    borderColor: colors.primary,
  },
  categoryChipText: {
    ...typography.button,
    fontSize: 15,
    color: colors.textPrimary,
  },
  categoryChipTextSelected: {
    color: colors.textOnPrimary,
  },
  stepperContainer: {
    flexDirection: "row",
    alignItems: "center",
    marginTop: spacing.md,
  },
  stepperButton: {
    width: 44,
    height: 44,
    backgroundColor: colors.surfaceElevated,
    borderColor: colors.surfaceBorder,
    borderWidth: 1,
    borderRadius: borderRadius.md,
    alignItems: "center",
    justifyContent: "center",
  },
  stepperButtonDisabled: {
    opacity: 0.4,
  },
  stepperButtonText: {
    fontFamily: courierFont,
    fontSize: 22,
    fontWeight: "bold",
    color: colors.textPrimary,
  },
  stepperButtonTextDisabled: {
    color: colors.textMuted,
  },
  stepperValueContainer: {
    width: 60,
    alignItems: "center",
  },
  stepperValueText: {
    ...typography.h2,
    fontSize: 22,
    color: colors.textPrimary,
  },
  switchRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
  },
  switchTextContainer: {
    flex: 1,
    marginRight: spacing.md,
  },
  playerInputRow: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: colors.surfaceElevated,
    borderColor: colors.surfaceBorder,
    borderWidth: 1,
    borderRadius: borderRadius.md,
    paddingHorizontal: spacing.md,
    height: 48,
    marginBottom: spacing.sm,
  },
  playerNumberBadge: {
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: colors.surface,
    borderColor: colors.surfaceBorder,
    borderWidth: 1,
    alignItems: "center",
    justifyContent: "center",
    marginRight: spacing.sm,
  },
  playerNumberText: {
    fontFamily: courierFont,
    fontSize: 12,
    fontWeight: "700",
    color: colors.textSecondary,
  },
  playerInput: {
    flex: 1,
    ...typography.body,
    fontSize: 15,
    color: colors.textPrimary,
    height: "100%",
  },
  movePlayerBtn: {
    paddingHorizontal: 6,
    paddingVertical: 4,
    marginRight: 4,
    borderRadius: borderRadius.sm,
    backgroundColor: colors.surfaceElevated,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
    alignItems: "center",
    justifyContent: "center",
  },
  movePlayerText: {
    fontFamily: courierFont,
    fontSize: 15,
    fontWeight: "700",
    color: colors.textSecondary,
  },
  removePlayerBtn: {
    padding: spacing.xs,
  },
  removePlayerText: {
    fontFamily: courierFont,
    fontSize: 14,
    fontWeight: "700",
    color: colors.textMuted,
  },
  addPlayerBtn: {
    backgroundColor: colors.surface,
    borderColor: colors.surfaceBorderDark,
    borderWidth: 1,
    borderStyle: "dashed",
    borderRadius: borderRadius.md,
    height: 44,
    alignItems: "center",
    justifyContent: "center",
    marginTop: spacing.xs,
  },
  addPlayerBtnText: {
    ...typography.button,
    fontSize: 14,
    color: colors.textPrimary,
  },
  footer: {
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
    backgroundColor: colors.surface,
    borderTopWidth: 1,
    borderTopColor: colors.surfaceBorder,
  },
  startButton: {
    width: "100%",
  },
  saveGroupBtn: {
    backgroundColor: colors.surfaceElevated,
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: borderRadius.sm,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
  },
  saveGroupBtnText: {
    fontFamily: courierFont,
    fontSize: 12,
    fontWeight: "700",
    color: colors.primary,
  },
  groupChipsContainer: {
    paddingVertical: 8,
    gap: 8,
  },
  groupChip: {
    backgroundColor: colors.surfaceElevated,
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 16,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
  },
  groupChipSelected: {
    backgroundColor: colors.primary,
    borderColor: colors.primary,
  },
  groupChipText: {
    fontFamily: courierFont,
    fontSize: 12,
    fontWeight: "700",
    color: colors.textPrimary,
  },
  groupChipTextSelected: {
    color: colors.textOnPrimary,
  },
  activeGroupBanner: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    backgroundColor: colors.surfaceElevated,
    paddingHorizontal: 10,
    paddingVertical: 6,
    borderRadius: borderRadius.sm,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
    marginBottom: spacing.sm,
  },
  activeGroupText: {
    flex: 1,
    fontFamily: courierFont,
    fontSize: 13,
    fontWeight: "700",
    color: colors.textPrimary,
  },
  activeGroupActions: {
    flexDirection: "row",
    alignItems: "center",
    gap: 10,
  },
  groupActionBtn: {
    padding: 2,
  },
  groupActionBtnText: {
    fontFamily: courierFont,
    fontSize: 14,
    fontWeight: "700",
    color: colors.textSecondary,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: "rgba(0,0,0,0.5)",
    justifyContent: "center",
    alignItems: "center",
    padding: spacing.lg,
  },
  modalCard: {
    width: "100%",
    maxWidth: 340,
    backgroundColor: colors.surface,
    borderRadius: borderRadius.md,
    padding: spacing.md,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
  },
  modalTitle: {
    fontFamily: courierFont,
    fontSize: 16,
    fontWeight: "700",
    color: colors.textPrimary,
    marginBottom: 4,
  },
  modalSubtitle: {
    fontFamily: courierFont,
    fontSize: 12,
    color: colors.textSecondary,
    marginBottom: spacing.sm,
  },
  modalInput: {
    backgroundColor: colors.surfaceElevated,
    borderRadius: borderRadius.sm,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.xs,
    fontFamily: courierFont,
    fontSize: 14,
    color: colors.textPrimary,
    marginBottom: spacing.md,
  },
  modalActions: {
    flexDirection: "row",
    justifyContent: "flex-end",
    gap: spacing.sm,
  },
  modalHeaderRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
    marginBottom: 6,
  },
  modalDangerIconBadge: {
    backgroundColor: "rgba(220, 38, 38, 0.1)",
    padding: 6,
    borderRadius: borderRadius.sm,
  },
  modalDangerIconText: {
    fontSize: 16,
  },
  modalCancelBtn: {
    paddingVertical: 7,
    paddingHorizontal: 14,
    borderRadius: borderRadius.sm,
    borderWidth: 1,
    borderColor: colors.surfaceBorderDark,
  },
  modalCancelText: {
    fontFamily: courierFont,
    fontSize: 13,
    fontWeight: "700",
    color: colors.textSecondary,
  },
  modalConfirmBtn: {
    backgroundColor: colors.primary,
    paddingVertical: 7,
    paddingHorizontal: 14,
    borderRadius: borderRadius.sm,
  },
  modalConfirmText: {
    fontFamily: courierFont,
    fontSize: 13,
    fontWeight: "700",
    color: colors.textOnPrimary,
  },
  modalDeleteConfirmBtn: {
    backgroundColor: colors.danger,
    paddingVertical: 7,
    paddingHorizontal: 14,
    borderRadius: borderRadius.sm,
  },
  modalDeleteConfirmText: {
    fontFamily: courierFont,
    fontSize: 13,
    fontWeight: "700",
    color: "#FFFFFF",
  },
});
