import React, { useState } from "react";
import {
  View,
  Text,
  TextInput,
  StyleSheet,
  ScrollView,
  Pressable,
} from "react-native";
import { colors, spacing, borderRadius } from "../theme";
import { HangmanState } from "../domain/hangman";

interface HangmanTeamSetupScreenProps {
  state: HangmanState;
  onBackToHub: () => void;
  onProceedToWordEntry: (params: {
    teamAName: string;
    teamBName: string;
  }) => void;
}

export const HangmanTeamSetupScreen: React.FC<HangmanTeamSetupScreenProps> = ({
  state,
  onBackToHub,
  onProceedToWordEntry,
}) => {
  const [teamAName, setTeamAName] = useState(state.teamAName);
  const [teamBName, setTeamBName] = useState(state.teamBName);

  const handleSubmit = () => {
    onProceedToWordEntry({
      teamAName: teamAName.trim() || "Team Popcorn",
      teamBName: teamBName.trim() || "Team Cinema",
    });
  };

  return (
    <View style={styles.container}>
      {/* Top Bar */}
      <View style={styles.topBar}>
        <Pressable
          style={styles.backButton}
          onPress={onBackToHub}
          accessibilityLabel="Back to Game Hub"
        >
          <Text style={styles.backButtonText}>←</Text>
        </Pressable>
        <Text style={styles.title}>Team Setup</Text>
      </View>

      <ScrollView
        contentContainerStyle={styles.scrollContent}
        keyboardShouldPersistTaps="handled"
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.desktopConstraint}>
          {/* Session Scoreboard Card */}
          <View style={styles.scoreboardCard}>
            <Text style={styles.scoreboardTitle}>SESSION SCOREBOARD</Text>
            <View style={styles.scoreboardRow}>
              <View style={styles.scoreboardTeam}>
                <Text style={styles.scoreboardScore}>{state.scoreTeamA}</Text>
                <Text style={styles.scoreboardName} numberOfLines={1}>
                  {teamAName.trim() || "Team Popcorn"}
                </Text>
              </View>
              <Text style={styles.scoreboardVs}>VS</Text>
              <View style={styles.scoreboardTeam}>
                <Text style={[styles.scoreboardScore, styles.scoreAmber]}>
                  {state.scoreTeamB}
                </Text>
                <Text style={styles.scoreboardName} numberOfLines={1}>
                  {teamBName.trim() || "Team Cinema"}
                </Text>
              </View>
            </View>
          </View>

          {/* Team Names Inputs */}
          <View style={styles.inputCard}>
            <Text style={styles.sectionHeader}>TEAM NAMES</Text>

            <View style={styles.fieldGroup}>
              <Text style={styles.fieldLabel}>
                {state.settingTeam === "teamA"
                  ? "Team A Name (Setting Word)"
                  : "Team A Name (Guessing)"}
              </Text>
              <TextInput
                style={styles.input}
                value={teamAName}
                onChangeText={setTeamAName}
                placeholder="Team Popcorn"
                placeholderTextColor={colors.textMuted}
                maxLength={20}
              />
            </View>

            <View style={styles.fieldGroup}>
              <Text style={styles.fieldLabel}>
                {state.settingTeam === "teamB"
                  ? "Team B Name (Setting Word)"
                  : "Team B Name (Guessing)"}
              </Text>
              <TextInput
                style={styles.input}
                value={teamBName}
                onChangeText={setTeamBName}
                placeholder="Team Cinema"
                placeholderTextColor={colors.textMuted}
                maxLength={20}
              />
            </View>
          </View>

          {/* Scoring Rules Notice (Clean 1-line text) */}
          <View style={styles.rulesCard}>
            <Text style={styles.rulesTitle}>Scoring Rules</Text>
            <Text style={styles.ruleBullet}>• Guess without clues: +2 Points</Text>
            <Text style={styles.ruleBullet}>• Guess with clues opened: +1 Point</Text>
            <Text style={styles.ruleBullet}>• 7 strikes hit: Setting team +1 Pt</Text>
          </View>

          {/* Action CTA Button */}
          <Pressable
            style={({ pressed }) => [
              styles.actionButton,
              pressed && styles.actionButtonPressed,
            ]}
            onPress={handleSubmit}
          >
            <Text style={styles.actionButtonText}>Enter Secret Word →</Text>
          </Pressable>
        </View>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  topBar: {
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
  },
  backButton: {
    width: 36,
    height: 36,
    borderRadius: borderRadius.md,
    backgroundColor: colors.surfaceElevated,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
    alignItems: "center",
    justifyContent: "center",
    marginRight: spacing.md,
  },
  backButtonText: {
    fontSize: 18,
    color: colors.textPrimary,
    fontWeight: "700",
  },
  title: {
    fontSize: 20,
    fontWeight: "800",
    color: colors.textPrimary,
  },
  scrollContent: {
    paddingHorizontal: spacing.lg,
    paddingBottom: spacing.xl,
    alignItems: "center",
  },
  desktopConstraint: {
    width: "100%",
    maxWidth: 500,
  },
  scoreboardCard: {
    backgroundColor: colors.surface,
    borderRadius: borderRadius.lg,
    padding: spacing.md,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
    marginBottom: spacing.md,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.04,
    shadowRadius: 8,
    elevation: 2,
  },
  scoreboardTitle: {
    fontSize: 10,
    fontWeight: "800",
    color: colors.textMuted,
    letterSpacing: 0.8,
    textAlign: "center",
    marginBottom: spacing.sm,
  },
  scoreboardRow: {
    flexDirection: "row",
    justifyContent: "space-around",
    alignItems: "center",
  },
  scoreboardTeam: {
    alignItems: "center",
    flex: 1,
  },
  scoreboardScore: {
    fontSize: 28,
    fontWeight: "900",
    color: colors.textPrimary,
  },
  scoreAmber: {
    color: "#A55704",
  },
  scoreboardName: {
    fontSize: 12,
    fontWeight: "700",
    color: colors.textSecondary,
    marginTop: 2,
  },
  scoreboardVs: {
    fontSize: 12,
    fontWeight: "700",
    color: colors.textMuted,
    paddingHorizontal: spacing.sm,
  },
  inputCard: {
    backgroundColor: colors.surface,
    borderRadius: borderRadius.lg,
    padding: spacing.md,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
    marginBottom: spacing.md,
  },
  sectionHeader: {
    fontSize: 10,
    fontWeight: "800",
    color: colors.textMuted,
    letterSpacing: 0.8,
    marginBottom: spacing.sm,
  },
  fieldGroup: {
    marginBottom: spacing.sm,
  },
  fieldLabel: {
    fontSize: 12,
    fontWeight: "700",
    color: colors.textPrimary,
    marginBottom: 4,
  },
  input: {
    backgroundColor: colors.background,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
    borderRadius: borderRadius.md,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.sm,
    fontSize: 14,
    fontWeight: "700",
    color: colors.textPrimary,
  },
  rulesCard: {
    backgroundColor: colors.surfaceElevated,
    borderRadius: borderRadius.md,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
    padding: spacing.md,
    marginBottom: spacing.lg,
  },
  rulesTitle: {
    fontSize: 12,
    fontWeight: "800",
    color: colors.textPrimary,
    marginBottom: 6,
  },
  ruleBullet: {
    fontSize: 11,
    fontWeight: "600",
    color: colors.textSecondary,
    marginBottom: 3,
  },
  actionButton: {
    backgroundColor: "#A55704",
    borderRadius: borderRadius.lg,
    paddingVertical: spacing.md,
    alignItems: "center",
    shadowColor: "#A55704",
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.25,
    shadowRadius: 8,
    elevation: 3,
  },
  actionButtonPressed: {
    opacity: 0.88,
    transform: [{ scale: 0.99 }],
  },
  actionButtonText: {
    fontSize: 15,
    fontWeight: "800",
    color: "#FFFFFF",
    letterSpacing: 0.5,
  },
});

