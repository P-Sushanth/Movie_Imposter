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
import {
  HangmanState,
  isLetterOrDigit,
  normalizeWord,
} from "../domain/hangman";

interface HangmanWordEntryScreenProps {
  state: HangmanState;
  onBackToTeamSetup: () => void;
  onLockWordAndPass: (params: {
    secretWord: string;
    clues: string[];
  }) => void;
}

export const HangmanWordEntryScreen: React.FC<HangmanWordEntryScreenProps> = ({
  state,
  onBackToTeamSetup,
  onLockWordAndPass,
}) => {
  const [secretWord, setSecretWord] = useState(state.secretWord);
  const [clue1, setClue1] = useState(state.clues[0] || "");
  const [clue2, setClue2] = useState(state.clues[1] || "");
  const [clue3, setClue3] = useState(state.clues[2] || "");
  const [obscureWord, setObscureWord] = useState(false);
  const [validationError, setValidationError] = useState<string | null>(null);

  const settingTeamName =
    state.settingTeam === "teamA" ? state.teamAName : state.teamBName;
  const guessingTeamName =
    state.settingTeam === "teamA" ? state.teamBName : state.teamAName;

  const handleSubmit = () => {
    const word = normalizeWord(secretWord);
    if (!word) {
      setValidationError("Please enter a secret word, movie, or phrase.");
      return;
    }

    let hasAlphanumeric = false;
    for (let i = 0; i < word.length; i++) {
      if (isLetterOrDigit(word[i])) {
        hasAlphanumeric = true;
        break;
      }
    }

    if (!hasAlphanumeric) {
      setValidationError("Word must include at least one letter or digit.");
      return;
    }

    const clues: string[] = [];
    if (clue1.trim()) clues.push(clue1.trim());
    if (clue2.trim()) clues.push(clue2.trim());
    if (clue3.trim()) clues.push(clue3.trim());

    onLockWordAndPass({
      secretWord: word,
      clues,
    });
  };

  return (
    <View style={styles.container}>
      {/* Top Bar */}
      <View style={styles.topBar}>
        <Pressable
          style={styles.backButton}
          onPress={onBackToTeamSetup}
          accessibilityLabel="Back to Team Setup"
        >
          <Text style={styles.backButtonText}>←</Text>
        </Pressable>
        <Text style={styles.title}>Word Entry</Text>
      </View>

      <ScrollView
        contentContainerStyle={styles.scrollContent}
        keyboardShouldPersistTaps="handled"
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.desktopConstraint}>
          {/* Word Creator Spotlight Banner (Deep Slate Midnight, High Contrast) */}
          <View style={styles.spotlightCard}>
            <View style={styles.spotlightTopRow}>
              <Text style={styles.spotlightCategory}>WORD CREATOR</Text>
              <View style={styles.settingBadge}>
                <Text style={styles.settingBadgeText}>SETTING TURN</Text>
              </View>
            </View>
            <Text style={styles.spotlightTeamName}>{settingTeamName}</Text>
            <View style={styles.spotlightBottomRow}>
              <Text style={styles.spotlightTarget} numberOfLines={1}>
                Target for: {guessingTeamName}
              </Text>
              <Text style={styles.shieldNotice}>Shield screen!</Text>
            </View>
          </View>

          {/* Secret Word Hero Card (Visually distinct with thick border & toggle) */}
          <View style={styles.heroCard}>
            <View style={styles.heroHeader}>
              <View style={styles.heroBadge}>
                <Text style={styles.heroBadgeText}>SECRET WORD *</Text>
              </View>
              <Text style={styles.heroSubtitle} numberOfLines={1}>
                {guessingTeamName} Guesses This
              </Text>
            </View>

            <View style={styles.secretWordInputWrapper}>
              <TextInput
                style={styles.secretWordInput}
                value={secretWord}
                onChangeText={(text) => {
                  setSecretWord(text);
                  if (validationError) setValidationError(null);
                }}
                placeholder="E.G. INTERSTELLAR"
                placeholderTextColor={colors.textMuted}
                autoCapitalize="characters"
                secureTextEntry={obscureWord}
                maxLength={40}
              />
              <Pressable
                style={styles.obscureToggle}
                onPress={() => setObscureWord(!obscureWord)}
              >
                <Text style={styles.obscureToggleText}>
                  {obscureWord ? "SHOW" : "HIDE"}
                </Text>
              </Pressable>
            </View>

            {validationError ? (
              <Text style={styles.errorText}>{validationError}</Text>
            ) : null}

            <Text style={styles.secretWordHelper}>
              Spaces and punctuation are revealed automatically.
            </Text>
          </View>

          {/* Optional Hints Card (Grouped neutral styling with numbered badges) */}
          <View style={styles.hintsCard}>
            <View style={styles.hintsHeader}>
              <Text style={styles.hintsTitle}>OPTIONAL HINTS (UP TO 3)</Text>
              <View style={styles.hintsCountBadge}>
                <Text style={styles.hintsCountText}>Max 3</Text>
              </View>
            </View>

            <View style={styles.hintRow}>
              <View style={styles.hintNumberBadge}>
                <Text style={styles.hintNumberText}>1</Text>
              </View>
              <TextInput
                style={styles.hintInput}
                value={clue1}
                onChangeText={setClue1}
                placeholder="Clue 1 (Optional)"
                placeholderTextColor={colors.textMuted}
                maxLength={50}
              />
            </View>

            <View style={styles.hintRow}>
              <View style={styles.hintNumberBadge}>
                <Text style={styles.hintNumberText}>2</Text>
              </View>
              <TextInput
                style={styles.hintInput}
                value={clue2}
                onChangeText={setClue2}
                placeholder="Clue 2 (Optional)"
                placeholderTextColor={colors.textMuted}
                maxLength={50}
              />
            </View>

            <View style={styles.hintRow}>
              <View style={styles.hintNumberBadge}>
                <Text style={styles.hintNumberText}>3</Text>
              </View>
              <TextInput
                style={styles.hintInput}
                value={clue3}
                onChangeText={setClue3}
                placeholder="Clue 3 (Optional)"
                placeholderTextColor={colors.textMuted}
                maxLength={50}
              />
            </View>

            <Text style={styles.hintsHelper}>
              Clues remain hidden. Guessing team can choose to view them during play.
            </Text>
          </View>

          {/* Action CTA Button */}
          <Pressable
            style={({ pressed }) => [
              styles.actionButton,
              pressed && styles.actionButtonPressed,
            ]}
            onPress={handleSubmit}
          >
            <Text style={styles.actionButtonText}>Lock Word & Pass Phone →</Text>
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
  spotlightCard: {
    backgroundColor: "#0F172A",
    borderRadius: borderRadius.lg,
    padding: spacing.md,
    marginBottom: spacing.md,
    borderWidth: 1,
    borderColor: "#1E293B",
  },
  spotlightTopRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 4,
  },
  spotlightCategory: {
    fontSize: 10,
    fontWeight: "900",
    color: "#D97706",
    letterSpacing: 1.0,
  },
  settingBadge: {
    backgroundColor: "#1E293B",
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 6,
    borderWidth: 1,
    borderColor: "#334155",
  },
  settingBadgeText: {
    fontSize: 9,
    fontWeight: "800",
    color: "#FBBF24",
    letterSpacing: 0.5,
  },
  spotlightTeamName: {
    fontSize: 24,
    fontWeight: "900",
    color: "#FFFFFF",
    letterSpacing: -0.5,
    marginBottom: 8,
  },
  spotlightBottomRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    paddingTop: 8,
    borderTopWidth: 1,
    borderTopColor: "#334155",
  },
  spotlightTarget: {
    fontSize: 12,
    fontWeight: "600",
    color: "rgba(255,255,255,0.7)",
    flex: 1,
    marginRight: 8,
  },
  shieldNotice: {
    fontSize: 11,
    fontWeight: "500",
    color: "rgba(255,255,255,0.4)",
  },
  heroCard: {
    backgroundColor: colors.surface,
    borderRadius: borderRadius.lg,
    padding: spacing.md,
    borderWidth: 2,
    borderColor: colors.primary,
    marginBottom: spacing.md,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.04,
    shadowRadius: 8,
    elevation: 2,
  },
  heroHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: spacing.sm,
  },
  heroBadge: {
    backgroundColor: colors.primary,
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 6,
  },
  heroBadgeText: {
    fontSize: 10,
    fontWeight: "900",
    color: "#FFFFFF",
    letterSpacing: 0.8,
  },
  heroSubtitle: {
    fontSize: 11,
    fontWeight: "600",
    color: colors.textSecondary,
    flex: 1,
    textAlign: "right",
    marginLeft: 8,
  },
  secretWordInputWrapper: {
    position: "relative",
    justifyContent: "center",
  },
  secretWordInput: {
    backgroundColor: colors.background,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
    borderRadius: borderRadius.md,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.sm,
    paddingRight: 64,
    fontSize: 16,
    fontWeight: "900",
    letterSpacing: 2.0,
    color: colors.textPrimary,
  },
  obscureToggle: {
    position: "absolute",
    right: 12,
    paddingVertical: 4,
    paddingHorizontal: 6,
  },
  obscureToggleText: {
    fontSize: 11,
    fontWeight: "800",
    color: colors.textSecondary,
    letterSpacing: 0.5,
  },
  errorText: {
    color: colors.danger,
    fontSize: 12,
    fontWeight: "700",
    marginTop: 6,
  },
  secretWordHelper: {
    fontSize: 11,
    color: colors.textMuted,
    marginTop: 6,
  },
  hintsCard: {
    backgroundColor: colors.surfaceElevated,
    borderRadius: borderRadius.lg,
    padding: spacing.md,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
    marginBottom: spacing.lg,
  },
  hintsHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: spacing.sm,
  },
  hintsTitle: {
    fontSize: 10,
    fontWeight: "800",
    color: colors.textPrimary,
    letterSpacing: 0.8,
  },
  hintsCountBadge: {
    backgroundColor: "#FFFFFF",
    borderRadius: 6,
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
  },
  hintsCountText: {
    fontSize: 10,
    fontWeight: "700",
    color: colors.textSecondary,
  },
  hintRow: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: spacing.sm,
  },
  hintNumberBadge: {
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
    alignItems: "center",
    justifyContent: "center",
    marginRight: 8,
  },
  hintNumberText: {
    fontSize: 11,
    fontWeight: "800",
    color: colors.textSecondary,
  },
  hintInput: {
    flex: 1,
    backgroundColor: colors.background,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
    borderRadius: borderRadius.md,
    paddingHorizontal: spacing.md,
    paddingVertical: 8,
    fontSize: 13,
    color: colors.textPrimary,
  },
  hintsHelper: {
    fontSize: 11,
    color: colors.textMuted,
    marginTop: 4,
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

