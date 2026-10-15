import React, { useState } from "react";
import { View, Text, StyleSheet, Alert } from "react-native";
import { colors, spacing, typography, borderRadius } from "../theme";
import { PrimaryButton } from "../components/PrimaryButton";

interface DiscussionScreenProps {
  movieTitle: string;
  imposters: string[];
  onReturnToSetup: () => void;
}

export const DiscussionScreen: React.FC<DiscussionScreenProps> = ({
  movieTitle,
  imposters,
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
