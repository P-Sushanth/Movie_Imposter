import React from "react";
import {
  View,
  Text,
  TextInput,
  StyleSheet,
  ScrollView,
  Pressable,
  Switch,
} from "react-native";
import { colors, spacing, typography, borderRadius, courierFont } from "../theme";
import { Industry } from "../data/movies/types";
import { PrimaryButton } from "../components/PrimaryButton";

interface SetupScreenProps {
  selectedIndustries: Industry[];
  onToggleIndustry: (industry: Industry) => void;
  onSelectAllIndustries: () => void;
  players: string[];
  onChangePlayer: (index: number, name: string) => void;
  onAddPlayer: () => void;
  onRemovePlayer: (index: number) => void;
  numImposters: number;
  onChangeNumImposters: (count: number) => void;
  imposterClueEnabled: boolean;
  onToggleClueEnabled: (enabled: boolean) => void;
  onStartGame: () => void;
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
  numImposters,
  onChangeNumImposters,
  imposterClueEnabled,
  onToggleClueEnabled,
  onStartGame,
}) => {
  const maxImposters = Math.max(1, Math.floor(players.length / 2));
  const canAddMorePlayers = players.length < 10;
  const canRemovePlayer = players.length > 3;

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
          <Text style={styles.title}>Movie Imposter</Text>
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

        {/* 2. Number of Imposters Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Number of Imposters</Text>
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
              <Text style={styles.stepperValueText}>{numImposters}</Text>
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

        {/* 3. Imposter Hint Section */}
        <View style={styles.section}>
          <View style={styles.switchRow}>
            <View style={styles.switchTextContainer}>
              <Text style={styles.sectionTitle}>Imposter Hint</Text>
              <Text style={styles.sectionSubtitle}>
                {imposterClueEnabled
                  ? "Enabled — Imposter gets a subtle clue"
                  : "Disabled — Imposter gets no clues"}
              </Text>
            </View>
            <Switch
              value={imposterClueEnabled}
              onValueChange={onToggleClueEnabled}
              trackColor={{ false: "#CBD5E1", true: colors.primary }}
              thumbColor={colors.surface}
            />
          </View>
        </View>

        {/* 4. Players Section */}
        <View style={styles.section}>
          <View style={styles.sectionHeaderRow}>
            <Text style={styles.sectionTitle}>Players ({players.length})</Text>
            <Text style={styles.sectionSubtitleInline}>
              Leave blank for default names
            </Text>
          </View>

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
});
