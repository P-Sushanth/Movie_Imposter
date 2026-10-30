import React, { useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  Pressable,
  Modal,
} from "react-native";
import { colors, spacing, borderRadius } from "../theme";
import {
  HangmanState,
  HANGMAN_LETTERS,
  MAX_STRIKES,
  getStrikeCount,
  getWrongGuesses,
  isWordGuessed,
  isHangmanExpired,
  isRoundOver,
  calculateRoundOutcome,
  normalizeWord,
  isLetterOrDigit,
} from "../domain/hangman";

interface HangmanArenaScreenProps {
  state: HangmanState;
  onGuessLetter: (letter: string) => void;
  onOpenClues: () => void;
  onNextRound: () => void;
  onBackToHub: () => void;
}

export const HangmanArenaScreen: React.FC<HangmanArenaScreenProps> = ({
  state,
  onGuessLetter,
  onOpenClues,
  onNextRound,
  onBackToHub,
}) => {
  const [showCluesModal, setShowCluesModal] = useState(false);

  const strikeCount = getStrikeCount(state.secretWord, state.guessedLetters);
  const isOver = isRoundOver(state.secretWord, state.guessedLetters);
  const outcome = isOver ? calculateRoundOutcome(state) : null;
  const wrongGuesses = new Set(getWrongGuesses(state.secretWord, state.guessedLetters));

  const settingTeamName =
    state.settingTeam === "teamA" ? state.teamAName : state.teamBName;
  const guessingTeamName =
    state.settingTeam === "teamA" ? state.teamBName : state.teamAName;

  const handleOpenClues = () => {
    onOpenClues();
    setShowCluesModal(true);
  };

  const normalizedWord = normalizeWord(state.secretWord);
  const words = normalizedWord.split(" ");

  const row0 = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
  const row1 = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"];
  const row2 = ["A", "S", "D", "F", "G", "H", "J", "K", "L"];
  const row3 = ["Z", "X", "C", "V", "B", "N", "M"];

  const renderKey = (char: string) => {
    const isGuessed = state.guessedLetters.has(char);
    const isWrong = isGuessed && !normalizedWord.includes(char);
    const isCorrect = isGuessed && normalizedWord.includes(char);

    let keyBg = "#FFFFFF";
    let textColor = colors.textPrimary;
    let borderColor = colors.surfaceBorderDark;

    if (isCorrect) {
      keyBg = colors.warmAmberBg;
      textColor = colors.warmAmber;
      borderColor = colors.warmAmberBorder;
    } else if (isWrong) {
      keyBg = colors.surfaceElevated;
      textColor = colors.textMuted;
      borderColor = colors.surfaceBorder;
    }

    return (
      <Pressable
        key={char}
        disabled={isGuessed || isOver}
        style={({ pressed }) => [
          styles.keypadKey,
          {
            backgroundColor: keyBg,
            borderColor,
          },
          pressed && styles.pressed,
        ]}
        onPress={() => onGuessLetter(char)}
      >
        <Text
          style={[
            styles.keypadText,
            { color: textColor },
            isWrong && styles.strikethroughKeyText,
          ]}
        >
          {char}
        </Text>
      </Pressable>
    );
  };

  return (
    <View style={styles.container}>
      {/* Top Single-Line Header */}
      <View style={styles.topHeader}>
        <Text style={styles.headerScoreText} numberOfLines={1}>
          {state.teamAName}: {state.scoreTeamA} | {state.teamBName}: {state.scoreTeamB}
        </Text>
        <Pressable
          style={({ pressed }) => [
            styles.cluesPill,
            state.cluesViewed && styles.cluesPillOpened,
            pressed && styles.pressed,
          ]}
          onPress={handleOpenClues}
        >
          <Text style={styles.cluesPillText}>[CLUES {state.clues.length}]</Text>
          <Text
            style={[
              styles.cluesPillBonus,
              state.cluesViewed && styles.cluesPillBonusDimmed,
            ]}
          >
            • {state.cluesViewed ? "+1 PT" : "+2 PTS"}
          </Text>
        </Pressable>
      </View>

      <View style={styles.mainArena}>
        {/* Turn Indicator Banner */}
        <View style={styles.turnBanner}>
          <Text style={styles.turnTitle}>
            {guessingTeamName.toUpperCase()}'S TURN TO GUESS
          </Text>
          <Text style={styles.turnSub}>Set by: {settingTeamName}</Text>
        </View>

        {/* 7-Strike HANGMAN Tracker */}
        <View style={styles.strikeCard}>
          <View style={styles.strikeHeader}>
            <Text style={styles.strikeTitle}>STRIKE TRACKER</Text>
            <Text
              style={[
                styles.strikeSub,
                strikeCount > 0 && styles.strikeSubRed,
              ]}
            >
              {strikeCount} Strikes ({MAX_STRIKES - strikeCount} Left)
            </Text>
          </View>

          <View style={styles.strikeBoxesRow}>
            {HANGMAN_LETTERS.map((letter, idx) => {
              const isStruck = idx < strikeCount;
              return (
                <View
                  key={idx}
                  style={[
                    styles.letterBox,
                    isStruck && styles.letterBoxStruck,
                  ]}
                >
                  <Text
                    style={[
                      styles.letterBoxText,
                      isStruck && styles.letterBoxTextStruck,
                    ]}
                  >
                    {letter}
                  </Text>
                  {isStruck ? <View style={styles.strikeLine} /> : null}
                </View>
              );
            })}
          </View>
        </View>

        {/* Word Blanks Card */}
        <View style={styles.blanksCard}>
          <ScrollView
            contentContainerStyle={styles.blanksContent}
            showsVerticalScrollIndicator={false}
          >
            <View style={styles.wordsWrap}>
              {words.map((word, wIdx) => (
                <View key={wIdx} style={styles.wordRow}>
                  {word.split("").map((ch, cIdx) => {
                    if (!isLetterOrDigit(ch)) {
                      return (
                        <Text key={cIdx} style={styles.punctuationText}>
                          {ch}
                        </Text>
                      );
                    }
                    const revealed = state.guessedLetters.has(ch);
                    return (
                      <View key={cIdx} style={styles.blankSlot}>
                        <Text style={styles.blankChar}>
                          {revealed ? ch : ""}
                        </Text>
                        <View
                          style={[
                            styles.blankUnderline,
                            revealed && styles.blankUnderlineRevealed,
                          ]}
                        />
                      </View>
                    );
                  })}
                </View>
              ))}
            </View>
          </ScrollView>
        </View>

        {/* Keypad */}
        <View style={styles.keypadContainer}>
          <View style={styles.keypadRow}>{row0.map(renderKey)}</View>
          <View style={styles.keypadRow}>{row1.map(renderKey)}</View>
          <View style={[styles.keypadRow, styles.keypadRowPadded]}>
            {row2.map(renderKey)}
          </View>
          <View style={[styles.keypadRow, styles.keypadRowPaddedExtra]}>
            {row3.map(renderKey)}
          </View>
        </View>
      </View>

      {/* Clues Modal */}
      <Modal visible={showCluesModal} transparent animationType="fade">
        <View style={styles.modalOverlay}>
          <View style={styles.cluesModalContainer}>
            <View style={styles.modalHeaderRow}>
              <Text style={styles.modalTitle}>
                {settingTeamName}'s Clues
              </Text>
              <Pressable onPress={() => setShowCluesModal(false)}>
                <Text style={styles.modalCloseText}>✕</Text>
              </Pressable>
            </View>

            <Text style={styles.cluesPenaltyNote}>
              • Note: Viewing clues reduces win reward from +2 pts to +1 pt.
            </Text>

            <View style={styles.cluesList}>
              {state.clues.length === 0 ? (
                <View style={styles.emptyCluesBox}>
                  <Text style={styles.emptyCluesText}>
                    No clues were provided for this word.
                  </Text>
                </View>
              ) : (
                state.clues.map((c, i) => (
                  <View key={i} style={styles.clueItem}>
                    <Text style={styles.clueItemText}>
                      {i + 1}. {c}
                    </Text>
                  </View>
                ))
              )}
            </View>

            <Pressable
              style={styles.modalPrimaryBtn}
              onPress={() => setShowCluesModal(false)}
            >
              <Text style={styles.modalPrimaryBtnText}>Back to Arena</Text>
            </Pressable>
          </View>
        </View>
      </Modal>

      {/* Outcome Modal (Rubber Stamp with NO EMOJIS) */}
      {isOver && outcome && !showCluesModal ? (
        <View style={styles.modalOverlay}>
          <View style={styles.outcomeModalContainer}>
            {/* Rubber Stamp (NO EMOJIS) */}
            <View
              style={[
                styles.rubberStamp,
                outcome.reason === "STRIKES_EXPIRED"
                  ? styles.stampRed
                  : styles.stampAmber,
              ]}
            >
              <Text
                style={[
                  styles.stampText,
                  outcome.reason === "STRIKES_EXPIRED"
                    ? styles.stampTextRed
                    : styles.stampTextAmber,
                ]}
              >
                {outcome.reason === "STRIKES_EXPIRED"
                  ? "[ HANGMAN EXPIRED ]"
                  : "[ WORD GUESSED ]"}
              </Text>
            </View>

            <Text style={styles.outcomeSub}>THE SECRET WORD WAS</Text>
            <Text style={styles.outcomeWord}>{normalizedWord}</Text>

            {/* Scoreboard Card */}
            <View style={styles.outcomeScoreCard}>
              <View style={styles.outcomeScoreHeader}>
                <Text style={styles.outcomeWinnerName}>
                  {outcome.winner === "teamA" ? state.teamAName : state.teamBName} Wins Round
                </Text>
                <View style={styles.outcomePtsPill}>
                  <Text style={styles.outcomePtsText}>
                    +{outcome.pointsAwarded} PTS
                  </Text>
                </View>
              </View>

              <Text style={styles.outcomeReasonDetail}>
                {outcome.reason === "GUESSED_WITHOUT_CLUES"
                  ? "Bonus: Solved without viewing clues (+2 Pts)!"
                  : outcome.reason === "GUESSED_WITH_CLUES"
                  ? "Solved with clues opened (+1 Pt)"
                  : "7 strikes exhausted! Setting team earns +1 Pt"}
              </Text>

              <View style={styles.outcomeTotalsRow}>
                <Text style={styles.outcomeTotalsLabel}>Session Score:</Text>
                <Text style={styles.outcomeTotalsValue}>
                  {state.teamAName} {outcome.updatedScoreTeamA} — {outcome.updatedScoreTeamB} {state.teamBName}
                </Text>
              </View>
            </View>

            <Pressable
              style={({ pressed }) => [
                styles.swapRoundBtn,
                pressed && styles.pressed,
              ]}
              onPress={onNextRound}
            >
              <Text style={styles.swapRoundBtnText}>
                Swap Roles & Next Round →
              </Text>
            </Pressable>

            <Pressable style={styles.backHubBtn} onPress={onBackToHub}>
              <Text style={styles.backHubBtnText}>Back to Game Hub</Text>
            </Pressable>
          </View>
        </View>
      ) : null}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  topHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    paddingHorizontal: spacing.md,
    paddingVertical: 10,
    backgroundColor: colors.surface,
    borderBottomWidth: 1,
    borderBottomColor: colors.surfaceBorder,
  },
  headerScoreText: {
    flex: 1,
    fontSize: 12,
    fontWeight: "700",
    color: colors.textPrimary,
  },
  cluesPill: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: colors.surfaceElevated,
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: colors.warmAmberBorder,
  },
  cluesPillOpened: {
    borderColor: colors.surfaceBorderDark,
  },
  cluesPillText: {
    fontSize: 11,
    fontWeight: "800",
    color: colors.textPrimary,
  },
  cluesPillBonus: {
    fontSize: 10,
    fontWeight: "800",
    color: colors.warmAmber,
    marginLeft: 4,
  },
  cluesPillBonusDimmed: {
    color: colors.textSecondary,
  },
  mainArena: {
    flex: 1,
    paddingHorizontal: spacing.md,
    paddingVertical: 6,
    justifyContent: "space-between",
  },
  turnBanner: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    backgroundColor: colors.surfaceElevated,
    borderRadius: 10,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
    paddingHorizontal: 12,
    paddingVertical: 8,
  },
  turnTitle: {
    fontSize: 11,
    fontWeight: "900",
    color: colors.textPrimary,
    letterSpacing: 0.6,
  },
  turnSub: {
    fontSize: 11,
    fontWeight: "500",
    color: colors.textSecondary,
  },
  strikeCard: {
    backgroundColor: colors.surface,
    borderRadius: 16,
    borderWidth: 1.5,
    borderColor: colors.surfaceBorder,
    paddingVertical: 8,
    paddingHorizontal: 10,
    alignItems: "center",
  },
  strikeHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    width: "100%",
    marginBottom: 6,
  },
  strikeTitle: {
    fontSize: 10,
    fontWeight: "800",
    color: colors.textMuted,
    letterSpacing: 0.8,
  },
  strikeSub: {
    fontSize: 10,
    fontWeight: "800",
    color: colors.textMuted,
  },
  strikeSubRed: {
    color: colors.imposterRed,
  },
  strikeBoxesRow: {
    flexDirection: "row",
    gap: 6,
  },
  letterBox: {
    width: 32,
    height: 38,
    borderRadius: 6,
    backgroundColor: colors.surface,
    borderWidth: 1.5,
    borderColor: colors.surfaceBorderDark,
    justifyContent: "center",
    alignItems: "center",
    position: "relative",
  },
  letterBoxStruck: {
    backgroundColor: "#FEE2E2",
    borderColor: "#FCA5A5",
  },
  letterBoxText: {
    fontSize: 16,
    fontWeight: "900",
    color: colors.textPrimary,
  },
  letterBoxTextStruck: {
    color: colors.imposterRed,
  },
  strikeLine: {
    position: "absolute",
    left: 4,
    right: 4,
    height: 2.5,
    backgroundColor: colors.imposterRed,
    borderRadius: 2,
  },
  blanksCard: {
    flex: 1,
    backgroundColor: colors.surface,
    borderRadius: 18,
    borderWidth: 1.5,
    borderColor: colors.surfaceBorder,
    padding: 12,
    justifyContent: "center",
    alignItems: "center",
    minHeight: 80,
  },
  blanksContent: {
    flexGrow: 1,
    justifyContent: "center",
    alignItems: "center",
  },
  wordsWrap: {
    flexDirection: "row",
    flexWrap: "wrap",
    justifyContent: "center",
    gap: 16,
  },
  wordRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 4,
  },
  punctuationText: {
    fontSize: 20,
    fontWeight: "900",
    color: colors.textPrimary,
  },
  blankSlot: {
    width: 22,
    alignItems: "center",
  },
  blankChar: {
    fontSize: 20,
    fontWeight: "900",
    color: colors.textPrimary,
    minHeight: 26,
  },
  blankUnderline: {
    width: "100%",
    height: 2.5,
    backgroundColor: colors.surfaceBorderDark,
    borderRadius: 1,
  },
  blankUnderlineRevealed: {
    backgroundColor: colors.textPrimary,
  },
  keypadContainer: {
    backgroundColor: colors.surface,
    borderRadius: 16,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
    padding: 6,
    gap: 4,
  },
  keypadRow: {
    flexDirection: "row",
    justifyContent: "center",
    gap: 3,
  },
  keypadRowPadded: {
    paddingHorizontal: 8,
  },
  keypadRowPaddedExtra: {
    paddingHorizontal: 16,
  },
  keypadKey: {
    flex: 1,
    height: 38,
    borderRadius: 6,
    borderWidth: 1.2,
    justifyContent: "center",
    alignItems: "center",
  },
  keypadText: {
    fontSize: 14,
    fontWeight: "800",
  },
  strikethroughKeyText: {
    textDecorationLine: "line-through",
  },
  modalOverlay: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: "rgba(0, 0, 0, 0.55)",
    justifyContent: "center",
    alignItems: "center",
    padding: spacing.lg,
    zIndex: 99,
  },
  cluesModalContainer: {
    backgroundColor: colors.surface,
    borderRadius: 20,
    borderWidth: 2,
    borderColor: colors.primary,
    padding: spacing.lg,
    width: "100%",
    maxWidth: 340,
  },
  modalHeaderRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
  },
  modalTitle: {
    fontSize: 16,
    fontWeight: "800",
    color: colors.textPrimary,
  },
  modalCloseText: {
    fontSize: 18,
    fontWeight: "700",
    color: colors.textSecondary,
    padding: 4,
  },
  cluesPenaltyNote: {
    fontSize: 11,
    fontWeight: "700",
    color: colors.danger,
    marginTop: 6,
    marginBottom: spacing.md,
  },
  cluesList: {
    gap: 8,
    marginBottom: spacing.md,
  },
  emptyCluesBox: {
    backgroundColor: colors.surfaceElevated,
    borderRadius: 10,
    padding: 12,
  },
  emptyCluesText: {
    fontSize: 12,
    fontStyle: "italic",
    color: colors.textSecondary,
  },
  clueItem: {
    backgroundColor: colors.surfaceElevated,
    borderRadius: 10,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
    paddingHorizontal: 12,
    paddingVertical: 10,
  },
  clueItemText: {
    fontSize: 13,
    fontWeight: "600",
    color: colors.textPrimary,
  },
  modalPrimaryBtn: {
    height: 44,
    backgroundColor: colors.primary,
    borderRadius: 12,
    justifyContent: "center",
    alignItems: "center",
  },
  modalPrimaryBtnText: {
    fontSize: 13,
    fontWeight: "700",
    color: "#FFFFFF",
  },
  outcomeModalContainer: {
    backgroundColor: colors.surface,
    borderRadius: 22,
    borderWidth: 2,
    borderColor: colors.surfaceBorder,
    padding: spacing.xl,
    width: "100%",
    maxWidth: 320,
    alignItems: "center",
  },
  rubberStamp: {
    borderWidth: 2.2,
    paddingHorizontal: 14,
    paddingVertical: 6,
    borderRadius: 4,
    transform: [{ rotate: "-3deg" }],
    marginBottom: spacing.md,
  },
  stampAmber: {
    borderColor: colors.warmAmber,
  },
  stampRed: {
    borderColor: colors.imposterRed,
  },
  stampText: {
    fontSize: 13,
    fontWeight: "900",
    letterSpacing: 1.2,
  },
  stampTextAmber: {
    color: colors.warmAmber,
  },
  stampTextRed: {
    color: colors.imposterRed,
  },
  outcomeSub: {
    fontSize: 10,
    fontWeight: "800",
    color: colors.textMuted,
    letterSpacing: 1.0,
  },
  outcomeWord: {
    fontSize: 20,
    fontWeight: "900",
    color: colors.textPrimary,
    letterSpacing: 1.0,
    marginTop: 4,
    marginBottom: spacing.md,
    textAlign: "center",
  },
  outcomeScoreCard: {
    backgroundColor: colors.surfaceElevated,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
    padding: spacing.md,
    width: "100%",
    marginBottom: spacing.lg,
  },
  outcomeScoreHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
  },
  outcomeWinnerName: {
    fontSize: 13,
    fontWeight: "800",
    color: colors.textPrimary,
  },
  outcomePtsPill: {
    backgroundColor: "#FFFFFF",
    borderRadius: 6,
    borderWidth: 1,
    borderColor: colors.surfaceBorder,
    paddingHorizontal: 8,
    paddingVertical: 2,
  },
  outcomePtsText: {
    fontSize: 11,
    fontWeight: "900",
    color: colors.warmAmber,
  },
  outcomeReasonDetail: {
    fontSize: 11,
    fontWeight: "500",
    color: colors.textSecondary,
    marginTop: 4,
  },
  outcomeTotalsRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    borderTopWidth: 1,
    borderTopColor: colors.surfaceBorder,
    paddingTop: 8,
    marginTop: 10,
  },
  outcomeTotalsLabel: {
    fontSize: 11,
    fontWeight: "700",
    color: colors.textSecondary,
  },
  outcomeTotalsValue: {
    fontSize: 12,
    fontWeight: "900",
    color: colors.textPrimary,
  },
  swapRoundBtn: {
    width: "100%",
    height: 48,
    backgroundColor: colors.warmAmber,
    borderRadius: 12,
    justifyContent: "center",
    alignItems: "center",
    marginBottom: 8,
  },
  swapRoundBtnText: {
    fontSize: 14,
    fontWeight: "800",
    color: "#FFFFFF",
  },
  backHubBtn: {
    width: "100%",
    height: 40,
    justifyContent: "center",
    alignItems: "center",
  },
  backHubBtnText: {
    fontSize: 13,
    fontWeight: "700",
    color: colors.textSecondary,
  },
  pressed: {
    opacity: 0.8,
  },
});
