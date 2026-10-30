import React from "react";
import { View, Text, StyleSheet, ScrollView, Pressable } from "react-native";
import { colors, spacing, typography, borderRadius } from "../theme";

interface GameHubScreenProps {
  onPlayImposter: () => void;
  onPlayHangman: () => void;
}

export const GameHubScreen: React.FC<GameHubScreenProps> = ({
  onPlayImposter,
  onPlayHangman,
}) => {
  return (
    <View style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        {/* Top Header & Version Badge */}
        <View style={styles.headerRow}>
          <Text style={styles.headerTitle}>Party Arcade</Text>
          <View style={styles.versionBadge}>
            <Text style={styles.versionText}>v1.3.1</Text>
          </View>
        </View>

        {/* User tagline requirement: strictly "Choose an offline party game to play with friends." */}
        <Text style={styles.headerSubtitle}>
          Choose an offline party game to play with friends.
        </Text>

        <View style={styles.cardsContainer}>
          {/* Game Card 1: Movie Imposter */}
          <View style={styles.gameCard}>
            <View style={styles.cardTopRow}>
              <View style={styles.iconContainer}>
                <Text style={styles.cardEmoji}>🕵️‍♂️</Text>
              </View>
              <View style={styles.neutralBadge}>
                <Text style={styles.neutralBadgeText}>3–10+ Players</Text>
              </View>
            </View>
            <Text style={styles.gameTitle}>Movie Imposter</Text>
            <Text style={styles.gameDescription}>
              Secret word bluffing & pass-and-play trivia deduction. Spot the imposter before time runs out!
            </Text>
            <Pressable
              style={({ pressed }) => [
                styles.primaryButton,
                pressed && styles.buttonPressed,
              ]}
              onPress={onPlayImposter}
            >
              <Text style={styles.primaryButtonText}>Play Imposter</Text>
            </Pressable>
          </View>

          {/* Game Card 2: Hangman Battle (10% #A55704 Focal Accent) */}
          <View style={styles.gameCard}>
            <View style={styles.cardTopRow}>
              <View style={styles.iconContainer}>
                <Text style={styles.cardEmoji}>⚔️</Text>
              </View>
              <View style={styles.amberBadge}>
                <Text style={styles.amberBadgeText}>2 Teams • New</Text>
              </View>
            </View>
            <Text style={styles.gameTitle}>Hangman Battle</Text>
            <Text style={styles.gameDescription}>
              Pass-and-play word duel with strike tracker and optional hints. Deduce without clues for +2 Points!
            </Text>
            <Pressable
              style={({ pressed }) => [
                styles.amberButton,
                pressed && styles.buttonPressed,
              ]}
              onPress={onPlayHangman}
            >
              <Text style={styles.amberButtonText}>Start Hangman</Text>
            </Pressable>
          </View>
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
  scrollContent: {
    padding: spacing.xl,
  },
  headerRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
  },
  headerTitle: {
    fontSize: 26,
    fontWeight: "800",
    color: colors.textPrimary,
    letterSpacing: -0.5,
  },
  versionBadge: {
    backgroundColor: colors.surfaceElevated,
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
  },
  versionText: {
    fontSize: 12,
    fontWeight: "700",
    color: colors.textSecondary,
  },
  headerSubtitle: {
    fontSize: 14,
    fontWeight: "500",
    color: colors.textSecondary,
    marginTop: 6,
    marginBottom: spacing.xl,
  },
  cardsContainer: {
    gap: spacing.lg,
  },
  gameCard: {
    backgroundColor: colors.surface,
    borderRadius: 20,
    borderWidth: 2,
    borderColor: colors.surfaceBorder,
    padding: spacing.lg,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.04,
    shadowRadius: 10,
    elevation: 2,
  },
  cardTopRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: spacing.md,
  },
  iconContainer: {
    width: 44,
    height: 44,
    borderRadius: 12,
    backgroundColor: colors.surfaceElevated,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
    justifyContent: "center",
    alignItems: "center",
  },
  cardEmoji: {
    fontSize: 22,
  },
  neutralBadge: {
    backgroundColor: colors.surfaceElevated,
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 8,
  },
  neutralBadgeText: {
    fontSize: 11,
    fontWeight: "700",
    color: colors.textSecondary,
  },
  amberBadge: {
    backgroundColor: colors.warmAmberBg,
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: colors.warmAmberBorder,
  },
  amberBadgeText: {
    fontSize: 11,
    fontWeight: "700",
    color: colors.warmAmber,
  },
  gameTitle: {
    fontSize: 18,
    fontWeight: "800",
    color: colors.textPrimary,
  },
  gameDescription: {
    fontSize: 13,
    fontWeight: "500",
    color: colors.textSecondary,
    lineHeight: 18,
    marginTop: 4,
    marginBottom: spacing.lg,
  },
  primaryButton: {
    height: 46,
    backgroundColor: colors.primary,
    borderRadius: borderRadius.md,
    justifyContent: "center",
    alignItems: "center",
  },
  primaryButtonText: {
    fontSize: 14,
    fontWeight: "700",
    color: "#FFFFFF",
  },
  amberButton: {
    height: 46,
    backgroundColor: colors.warmAmber,
    borderRadius: borderRadius.md,
    justifyContent: "center",
    alignItems: "center",
  },
  amberButtonText: {
    fontSize: 14,
    fontWeight: "700",
    color: "#FFFFFF",
  },
  buttonPressed: {
    opacity: 0.85,
  },
});

