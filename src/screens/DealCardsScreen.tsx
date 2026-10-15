import React, { useState, useRef } from "react";
import {
  View,
  Text,
  StyleSheet,
  Pressable,
  Animated,
} from "react-native";
import { colors, spacing, typography, borderRadius } from "../theme";
import { PrimaryButton } from "../components/PrimaryButton";
import { PlayerAssignment } from "../domain/types";

interface DealCardsScreenProps {
  assignments: PlayerAssignment[];
  currentCardIndex: number;
  onNextPlayer: () => void;
  onFinishDealing: () => void;
}

export const DealCardsScreen: React.FC<DealCardsScreenProps> = ({
  assignments,
  currentCardIndex,
  onNextPlayer,
  onFinishDealing,
}) => {
  const currentAssignment = assignments[currentCardIndex];
  const isLastPlayer = currentCardIndex >= assignments.length - 1;

  const [isRevealed, setIsRevealed] = useState(false);
  const [hasViewed, setHasViewed] = useState(false);

  // Flip animation value: 0 (front) to 180 (back)
  const animatedValue = useRef(new Animated.Value(0)).current;

  const handlePressIn = () => {
    setIsRevealed(true);
    setHasViewed(true);
    Animated.timing(animatedValue, {
      toValue: 180,
      duration: 200,
      useNativeDriver: true,
    }).start();
  };

  const handlePressOut = () => {
    Animated.timing(animatedValue, {
      toValue: 0,
      duration: 200,
      useNativeDriver: true,
    }).start(() => {
      setIsRevealed(false);
    });
  };

  const handleNext = () => {
    setHasViewed(false);
    setIsRevealed(false);
    animatedValue.setValue(0);
    if (isLastPlayer) {
      onFinishDealing();
    } else {
      onNextPlayer();
    }
  };

  if (!currentAssignment) return null;

  const role = currentAssignment.role;
  const isImposter = role.kind === "imposter";

  const frontInterpolate = animatedValue.interpolate({
    inputRange: [0, 180],
    outputRange: ["0deg", "180deg"],
  });

  const backInterpolate = animatedValue.interpolate({
    inputRange: [0, 180],
    outputRange: ["180deg", "360deg"],
  });

  const frontOpacity = animatedValue.interpolate({
    inputRange: [89, 90],
    outputRange: [1, 0],
  });

  const backOpacity = animatedValue.interpolate({
    inputRange: [89, 90],
    outputRange: [0, 1],
  });

  return (
    <View style={styles.container}>
      <View style={styles.centerSection}>
        <Pressable
          onPressIn={handlePressIn}
          onPressOut={handlePressOut}
          style={styles.cardPressable}
          accessibilityLabel="Hold card to reveal secret role"
        >
          {/* Front Face: Player Name & Hold Instruction */}
          <Animated.View
            style={[
              styles.cardFace,
              styles.cardFront,
              {
                transform: [{ rotateY: frontInterpolate }],
                opacity: frontOpacity,
              },
            ]}
          >
            <Text style={styles.playerName}>{currentAssignment.playerName}</Text>
            <View style={styles.holdInstructionBadge}>
              <Text style={styles.holdInstructionText}>Hold to Reveal</Text>
            </View>
          </Animated.View>

          {/* Back Face: Revealed Secret (Identical neutral background to prevent glasses/pupil reflection leaks) */}
          <Animated.View
            style={[
              styles.cardFace,
              styles.cardBack,
              {
                transform: [{ rotateY: backInterpolate }],
                opacity: backOpacity,
              },
            ]}
          >
            {isImposter ? (
              <View style={styles.revealContent}>
                <View style={styles.roleBadge}>
                  <Text style={styles.roleBadgeText}>YOUR ROLE</Text>
                </View>
                <Text style={styles.imposterTitle}>IMPOSTER</Text>
                {role.clueText ? (
                  <View style={styles.clueBox}>
                    <Text style={styles.clueText}>{role.clueText}</Text>
                  </View>
                ) : null}
              </View>
            ) : (
              <View style={styles.revealContent}>
                <View style={styles.roleBadge}>
                  <Text style={styles.roleBadgeText}>MOVIE</Text>
                </View>
                <Text style={styles.movieTitle}>{role.movieTitle}</Text>
              </View>
            )}
          </Animated.View>
        </Pressable>
      </View>

      {/* Next Player / Finish Button */}
      <View style={styles.footer}>
        <PrimaryButton
          title={isLastPlayer ? "Start Discussion" : "Next Player"}
          onPress={handleNext}
          disabled={!hasViewed}
          style={styles.nextButton}
        />
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
  cardPressable: {
    width: "100%",
    maxWidth: 340,
    height: 380,
  },
  cardFace: {
    width: "100%",
    height: "100%",
    borderRadius: borderRadius.xl,
    borderWidth: 1.5,
    justifyContent: "center",
    alignItems: "center",
    padding: spacing.xl,
    position: "absolute",
    backfaceVisibility: "hidden",
  },
  cardFront: {
    backgroundColor: colors.surface,
    borderColor: colors.surfaceBorderDark,
  },
  // Both Normal & Imposter share identical background and border to avoid any reflection tell
  cardBack: {
    backgroundColor: colors.surface,
    borderColor: colors.primary,
  },
  playerName: {
    ...typography.h1,
    fontSize: 32,
    color: colors.textPrimary,
    textAlign: "center",
    marginBottom: spacing.xl,
  },
  holdInstructionBadge: {
    backgroundColor: colors.surfaceElevated,
    borderColor: colors.surfaceBorder,
    borderWidth: 1,
    borderRadius: borderRadius.md,
    paddingVertical: spacing.sm,
    paddingHorizontal: spacing.lg,
  },
  holdInstructionText: {
    ...typography.button,
    fontSize: 14,
    color: colors.textSecondary,
  },
  revealContent: {
    alignItems: "center",
    justifyContent: "center",
    width: "100%",
  },
  roleBadge: {
    backgroundColor: colors.surfaceElevated,
    borderColor: colors.surfaceBorder,
    borderWidth: 1,
    borderRadius: borderRadius.full,
    paddingVertical: spacing.xs,
    paddingHorizontal: spacing.md,
    marginBottom: spacing.lg,
  },
  roleBadgeText: {
    ...typography.caption,
    fontSize: 12,
    color: colors.textSecondary,
    fontWeight: "700",
    letterSpacing: 1,
  },
  imposterTitle: {
    ...typography.h1,
    fontSize: 34,
    fontWeight: "900",
    color: colors.textPrimary, // Neutral color, no red reflection on glasses
    letterSpacing: 3,
    textAlign: "center",
    marginBottom: spacing.lg,
  },
  movieTitle: {
    ...typography.h1,
    fontSize: 32,
    lineHeight: 40,
    color: colors.textPrimary,
    textAlign: "center",
  },
  clueBox: {
    backgroundColor: colors.surfaceElevated,
    borderColor: colors.surfaceBorderDark,
    borderWidth: 1,
    borderRadius: borderRadius.md,
    paddingVertical: spacing.md,
    paddingHorizontal: spacing.lg,
    width: "100%",
    alignItems: "center",
  },
  clueText: {
    ...typography.h3,
    fontSize: 18,
    color: colors.textPrimary,
    textAlign: "center",
  },
  footer: {
    marginTop: spacing.md,
  },
  nextButton: {
    width: "100%",
  },
});
