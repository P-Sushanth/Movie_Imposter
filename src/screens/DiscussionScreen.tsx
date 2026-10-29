import React, { useState, useEffect } from "react";
import { View, Text, StyleSheet, Alert, Vibration } from "react-native";
import { colors, spacing, typography, borderRadius, courierFont } from "../theme";
import { PrimaryButton } from "../components/PrimaryButton";

interface DiscussionScreenProps {
  movieTitle: string;
  imposters: string[];
  startingPlayer?: string;
  discussionOrder?: string[];
  discussionTimerMinutes?: number;
  onReturnToSetup: () => void;
  onNextRound: () => void;
}

export const DiscussionScreen: React.FC<DiscussionScreenProps> = ({
  movieTitle,
  imposters,
  startingPlayer,
  discussionOrder,
  discussionTimerMinutes = 0,
  onReturnToSetup,
  onNextRound,
}) => {
  const [isRevealed, setIsRevealed] = useState(false);
  const [remainingSeconds, setRemainingSeconds] = useState(
    discussionTimerMinutes > 0 ? discussionTimerMinutes * 60 : 0
  );

  useEffect(() => {
    if (!discussionTimerMinutes || discussionTimerMinutes <= 0 || isRevealed) {
      return;
    }
    setRemainingSeconds(discussionTimerMinutes * 60);
    const interval = setInterval(() => {
      setRemainingSeconds((prev) => {
        if (prev <= 1) {
          clearInterval(interval);
          try {
            // Sustained high-intensity alert pattern (~3.7s total buzz):
            Vibration.vibrate([0, 700, 200, 700, 200, 700, 200, 1000]);
          } catch (_) {}
          return 0;
        }
        return prev - 1;
      });
    }, 1000);
    return () => {
      clearInterval(interval);
      try {
        Vibration.cancel();
      } catch (_) {}
    };
  }, [discussionTimerMinutes, isRevealed]);

  const formatTimer = (totalSeconds: number) => {
    const mins = Math.floor(totalSeconds / 60);
    const secs = totalSeconds % 60;
    return `${mins.toString().padStart(2, "0")}:${secs.toString().padStart(2, "0")}`;
  };

  const getTimerColors = (seconds: number) => {
    if (seconds <= 5) {
      // 5-second countdown: starts from the same 30s red (#D84315),
      // and smoothly transitions into bright red (#FF0000)
      const colorsMap: Record<number, { text: string; border: string; bg: string }> = {
        5: { text: "#D84315", border: "#FF5722", bg: "#FFF7F2" }, // Identical to 30s red
        4: { text: "#E03510", border: "#FF451B", bg: "#FFF4F0" },
        3: { text: "#E8280C", border: "#FF3415", bg: "#FFF2EF" },
        2: { text: "#F01B08", border: "#FF230E", bg: "#FFF0ED" },
        1: { text: "#F70D04", border: "#FF1107", bg: "#FFEFEB" },
        0: { text: "#FF0000", border: "#FF0000", bg: "#FFEAEA" }, // Vivid bright red
      };
      return colorsMap[seconds] || { text: "#FF0000", border: "#FF0000", bg: "#FFEAEA" };
    }
    if (seconds <= 30) {
      return {
        text: "#D84315",
        border: "#FF5722",
        bg: "#FFF7F2",
      };
    }
    return {
      text: colors.textPrimary,
      border: colors.surfaceBorder,
      bg: colors.surface,
    };
  };

  const handleNextRoundClick = () => {
    try {
      Vibration.cancel();
    } catch (_) {}
    Alert.alert(
      "Start Next Round?",
      "Are you sure you want to start the next round? The phone will be passed around from the first player again with a new name and the same imposter.",
      [
        { text: "Cancel", style: "cancel" },
        {
          text: "Next Round",
          onPress: onNextRound,
        },
      ]
    );
  };

  const handleRevealClick = () => {
    try {
      Vibration.cancel();
    } catch (_) {}
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

            {discussionTimerMinutes > 0 && (() => {
              const timerTheme = getTimerColors(remainingSeconds);
              return (
                <View
                  style={[
                    styles.timerCard,
                    {
                      backgroundColor: timerTheme.bg,
                      borderColor: timerTheme.border,
                    },
                  ]}
                >
                  <Text
                    style={[
                      styles.timerBadge,
                      { color: timerTheme.text },
                    ]}
                  >
                    {remainingSeconds === 0
                      ? "⏱️ TIME'S UP! VOTE NOW"
                      : "⏱️ DISCUSSION TIME REMAINING"}
                  </Text>
                  <Text
                    style={[
                      styles.timerText,
                      { color: timerTheme.text },
                    ]}
                  >
                    {formatTimer(remainingSeconds)}
                  </Text>
                </View>
              );
            })()}

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

      {/* Footer Buttons */}
      <View style={styles.footer}>
        {!isRevealed ? (
          <View style={styles.buttonStack}>
            <PrimaryButton
              title="Next Round"
              variant="primary"
              onPress={handleNextRoundClick}
              style={styles.actionButton}
            />
            <View style={{ height: spacing.sm }} />
            <PrimaryButton
              title="Reveal Imposter"
              variant="danger"
              onPress={handleRevealClick}
              style={styles.actionButton}
            />
          </View>
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
  buttonStack: {
    width: "100%",
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
  timerCard: {
    width: "100%",
    backgroundColor: colors.surface,
    borderWidth: 2,
    borderColor: colors.surfaceBorder,
    borderRadius: borderRadius.lg,
    padding: spacing.md,
    alignItems: "center",
    marginVertical: spacing.sm,
  },
  timerCardWarning: {
    backgroundColor: "#FFF7F2",
    borderColor: "#FF5722",
  },
  timerCardExpired: {
    backgroundColor: colors.imposterRedBg,
    borderColor: colors.imposterRed,
  },
  timerBadge: {
    ...typography.caption,
    fontSize: 11,
    fontWeight: "800",
    color: colors.textSecondary,
    letterSpacing: 1,
    marginBottom: spacing.xs,
  },
  timerBadgeWarning: {
    color: "#D84315",
  },
  timerBadgeExpired: {
    color: colors.imposterRed,
  },
  timerText: {
    fontSize: 36,
    fontWeight: "900",
    color: colors.textPrimary,
    fontFamily: courierFont,
    letterSpacing: 1.5,
  },
  timerTextWarning: {
    color: "#D84315",
  },
  timerTextExpired: {
    color: colors.imposterRed,
  },
});
