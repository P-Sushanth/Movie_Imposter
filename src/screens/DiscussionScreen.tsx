import React, { useState } from "react";
import { View, Text, StyleSheet, Alert } from "react-native";
import { colors, spacing, typography, borderRadius } from "../theme";
import { PrimaryButton } from "../components/PrimaryButton";

interface DiscussionScreenProps {
  movieTitle: string;
  imposters: string[];
  startingPlayer?: string;
  discussionOrder?: string[];
  onReturnToSetup: () => void;
}

export const DiscussionScreen: React.FC<DiscussionScreenProps> = ({
  movieTitle,
  imposters,
  startingPlayer,
  discussionOrder,
  onReturnToSetup,
}) => {
  const [isRevealed, setIsRevealed] = useState(false);

  const handleRevealClick = () => {
    // Step 13: Double verification prompt
    Alert.alert(
      "Reveal Imposter?",
      "Are you sure you want to end the discussion and reveal the imposter?",
      [
        { text: "Cancel", style: "cancel" },
        {
          text: "Yes, Reveal",
          style: "destructive",
          onPress: () => {
            setIsRevealed(true);
          },
        },
      ]
    );
  };

  return (
    <View style={styles.container}>
      <View style={styles.centerSection}>
        {!isRevealed ? (
          <>
            <Text style={styles.title}>Discussion Time</Text>
            <Text style={styles.subtitle}>
              Discuss the movie, ask questions, and find the imposter.
            </Text>

            {startingPlayer && (
              <View style={styles.startingCard}>
                <Text style={styles.startingBadge}>🎯 STARTS THE ROUND</Text>
                <Text style={styles.startingName}>{startingPlayer}</Text>
                <Text style={styles.startingDesc}>
                  {startingPlayer} speaks first or asks the first question!
                </Text>
              </View>
            )}

            {discussionOrder && discussionOrder.length > 0 && (
              <View style={styles.orderCard}>
                <Text style={styles.orderHeader}>SPEAKING ORDER</Text>
                <View style={styles.orderChips}>
                  {discussionOrder.map((player, idx) => (
                    <View
                      key={player}
                      style={[
                        styles.orderChip,
                        idx === 0 && styles.firstOrderChip,
                      ]}
                    >
                      <Text
                        style={[
                          styles.orderIndex,
                          idx === 0 && styles.firstOrderText,
                        ]}
                      >
                        {idx + 1}.
                      </Text>
                      <Text
                        style={[
                          styles.orderPlayer,
                          idx === 0 && styles.firstOrderText,
                        ]}
                      >
                        {player}
                      </Text>
                    </View>
                  ))}
                </View>
              </View>
            )}
          </>
        ) : (
          <View style={styles.revealedBox}>
            <Text style={styles.revealedHeader}>
              {imposters.length > 1 ? "The Imposters Were" : "The Imposter Was"}
            </Text>
            <Text style={styles.imposterNames}>{imposters.join(", ")}</Text>

            <View style={styles.movieDivider} />

            <Text style={styles.movieLabel}>The Movie</Text>
            <Text style={styles.movieTitle}>{movieTitle}</Text>
          </View>
        )}
      </View>

      {/* Step 12: Single button */}
      <View style={styles.footer}>
        {!isRevealed ? (
          <PrimaryButton
            title="Reveal Imposter"
            variant="danger"
            onPress={handleRevealClick}
            style={styles.actionButton}
          />
        ) : (
          <PrimaryButton
            title="Back to Setup"
            variant="primary"
            onPress={onReturnToSetup}
            style={styles.actionButton}
          />
        )}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
    paddingHorizontal: spacing.xl,
    paddingTop: spacing.xxxl,
    paddingBottom: spacing.xl,
    justifyContent: "space-between",
  },
  centerSection: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
  },
  title: {
    ...typography.h1,
    fontSize: 32,
    color: colors.textPrimary,
    textAlign: "center",
    marginBottom: spacing.sm,
  },
  subtitle: {
    ...typography.body,
    fontSize: 16,
    color: colors.textSecondary,
    textAlign: "center",
    lineHeight: 22,
    maxWidth: 280,
    marginBottom: spacing.md,
  },
  startingCard: {
    width: "100%",
    backgroundColor: colors.surface,
    borderWidth: 2,
    borderColor: colors.surfaceBorder,
    borderRadius: borderRadius.lg,
    padding: spacing.md,
    alignItems: "center",
    marginVertical: spacing.sm,
  },
  startingBadge: {
    ...typography.caption,
    fontSize: 11,
    fontWeight: "800",
    color: colors.primary,
    letterSpacing: 1,
    marginBottom: spacing.xs,
  },
  startingName: {
    ...typography.h1,
    fontSize: 26,
    color: colors.textPrimary,
    textAlign: "center",
    marginBottom: 4,
  },
  startingDesc: {
    ...typography.caption,
    fontSize: 12,
    color: colors.textSecondary,
    textAlign: "center",
  },
  orderCard: {
    width: "100%",
    backgroundColor: colors.surface,
    borderWidth: 1.5,
    borderColor: colors.surfaceBorder,
    borderRadius: borderRadius.lg,
    padding: spacing.md,
    marginTop: spacing.sm,
  },
  orderHeader: {
    ...typography.caption,
    fontSize: 11,
    fontWeight: "800",
    color: colors.textMuted,
    letterSpacing: 1,
    marginBottom: spacing.sm,
  },
  orderChips: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 6,
  },
  orderChip: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: colors.surfaceElevated,
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: borderRadius.md,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
  },
  firstOrderChip: {
    backgroundColor: colors.primary,
    borderColor: colors.primary,
  },
  orderIndex: {
    ...typography.caption,
    fontSize: 11,
    fontWeight: "800",
    color: colors.textMuted,
    marginRight: 4,
  },
  orderPlayer: {
    ...typography.body,
    fontSize: 12,
    fontWeight: "700",
    color: colors.textPrimary,
  },
  firstOrderText: {
    color: colors.textOnPrimary,
  },
  revealedBox: {
    width: "100%",
    backgroundColor: colors.surface,
    borderColor: colors.surfaceBorderDark,
    borderWidth: 1.5,
    borderRadius: borderRadius.xl,
    padding: spacing.xl,
    alignItems: "center",
  },
  revealedHeader: {
    ...typography.caption,
    fontSize: 13,
    color: colors.imposterRed,
    fontWeight: "700",
    marginBottom: spacing.xs,
  },
  imposterNames: {
    ...typography.h1,
    fontSize: 30,
    color: colors.imposterRed,
    textAlign: "center",
    marginBottom: spacing.lg,
  },
  movieDivider: {
    width: 60,
    height: 1,
    backgroundColor: colors.surfaceBorderDark,
    marginVertical: spacing.md,
  },
  movieLabel: {
    ...typography.caption,
    fontSize: 13,
    color: colors.textMuted,
    fontWeight: "700",
    marginBottom: spacing.xs,
  },
  movieTitle: {
    ...typography.h2,
    fontSize: 24,
    color: colors.textPrimary,
    textAlign: "center",
  },
  footer: {
    marginTop: spacing.md,
  },
  actionButton: {
    width: "100%",
  },
});
