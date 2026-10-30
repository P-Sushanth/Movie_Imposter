import 'package:flutter/material.dart';
import '../domain/hangman.dart';
import '../theme/app_colors.dart';

class HangmanArenaScreen extends StatefulWidget {
  final HangmanState state;
  final void Function(String letter) onGuessLetter;
  final VoidCallback onOpenClues;
  final VoidCallback onNextRound;
  final VoidCallback onBackToHub;

  const HangmanArenaScreen({
    super.key,
    required this.state,
    required this.onGuessLetter,
    required this.onOpenClues,
    required this.onNextRound,
    required this.onBackToHub,
  });

  @override
  State<HangmanArenaScreen> createState() => _HangmanArenaScreenState();
}

class _HangmanArenaScreenState extends State<HangmanArenaScreen> {
  bool _showCluesModal = false;

  void _handleOpenClues() {
    widget.onOpenClues();
    setState(() {
      _showCluesModal = true;
    });
  }

  void _handleCloseClues() {
    setState(() {
      _showCluesModal = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final strikeCount = getStrikeCount(state.secretWord, state.guessedLetters);
    final isOver = isRoundOver(state.secretWord, state.guessedLetters);
    final outcome = isOver ? calculateRoundOutcome(state) : null;
    final wrongGuesses = getWrongGuesses(state.secretWord, state.guessedLetters).toSet();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Stack(
              children: [
                Column(
                  children: [
                    // Single-line top header: "Popcorn 2 - 1 Cinema | [CLUES 3] • +2 PTS"
                    _buildCompactHeader(state),

                    // Main Game Arena Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Guessing Turn Banner
                            _buildTurnBanner(state),
                            const SizedBox(height: 10),

                            // HANGMAN 7-Strike Tracker
                            _buildStrikeTracker(strikeCount),
                            const SizedBox(height: 10),

                            // Word Blanks Card
                            Expanded(
                              child: _buildWordBlanksCard(state),
                            ),
                            const SizedBox(height: 10),

                            // On-Screen Keypad
                            _buildKeypad(state, wrongGuesses, isOver),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Clues Modal Overlay
                if (_showCluesModal) _buildCluesDialog(state),

                // Outcome Modal Overlay (when round is over)
                if (isOver && outcome != null && !_showCluesModal)
                  _buildOutcomeDialog(state, outcome),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Compact single-line header strictly avoiding any wrapping
  Widget _buildCompactHeader(HangmanState state) {
    final cluesCount = state.clues.length;
    final pointsBonus = state.cluesViewed ? '+1 PT' : '+2 PTS';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Score summary (fits in single line)
          Expanded(
            child: Text(
              '${state.teamAName}: ${state.scoreTeamA}  |  ${state.teamBName}: ${state.scoreTeamB}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Clues Pill button (compact & single line)
          InkWell(
            onTap: _handleOpenClues,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: state.cluesViewed
                      ? AppColors.surfaceBorderDark
                      : AppColors.warmAmberBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '[CLUES $cluesCount]',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '• $pointsBonus',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: state.cluesViewed
                          ? AppColors.textSecondary
                          : AppColors.warmAmber,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Turn indicator banner
  Widget _buildTurnBanner(HangmanState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              "${state.guessingTeamName.toUpperCase()}'S TURN TO GUESS",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Set by: ${state.settingTeamName}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 7-Strike Tracker with clean centered horizontal strike line across letter boxes
  Widget _buildStrikeTracker(int strikeCount) {
    final strikesLeft = maxStrikes - strikeCount;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'STRIKE TRACKER',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                strikeCount == 0
                    ? '0 Strikes ($strikesLeft Left)'
                    : '$strikeCount Strikes ($strikesLeft Left)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: strikeCount > 0 ? AppColors.imposterRed : AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(hangmanLetters.length, (index) {
              final letter = hangmanLetters[index];
              final isStruck = index < strikeCount;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  width: 32,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isStruck
                        ? const Color(0xFFFEE2E2)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isStruck
                          ? const Color(0xFFFCA5A5)
                          : AppColors.surfaceBorderDark,
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        letter,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: isStruck
                              ? AppColors.imposterRed
                              : AppColors.textPrimary,
                        ),
                      ),
                      // Clean, centered horizontal strike bar
                      if (isStruck)
                        Positioned(
                          left: 4,
                          right: 4,
                          child: Container(
                            height: 2.5,
                            decoration: BoxDecoration(
                              color: AppColors.imposterRed,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Word Blanks Card nicely wrapping words without splitting characters
  Widget _buildWordBlanksCard(HangmanState state) {
    final words = normalizeWord(state.secretWord).split(' ');
    final upperGuesses = state.guessedLetters.map((c) => c.toUpperCase()).toSet();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 14,
          children: words.map((word) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: word.split('').map((ch) {
                if (!isLetterOrDigit(ch)) {
                  // Punctuation like dashes, colons, apostrophes
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      ch,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }

                final isRevealed = upperGuesses.contains(ch);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.5),
                  child: Container(
                    width: 24,
                    height: 34,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isRevealed
                              ? AppColors.textPrimary
                              : AppColors.surfaceBorderDark,
                          width: 2.5,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isRevealed ? ch : '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Keypad grid (Numbers row + QWERTY letter rows)
  Widget _buildKeypad(
    HangmanState state,
    Set<String> wrongGuesses,
    bool isOver,
  ) {
    const row0 = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const row1 = ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'];
    const row2 = ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'];
    const row3 = ['Z', 'X', 'C', 'V', 'B', 'N', 'M'];

    final upperGuesses = state.guessedLetters.map((c) => c.toUpperCase()).toSet();
    final normalizedWord = normalizeWord(state.secretWord);

    Widget buildKey(String char) {
      final isGuessed = upperGuesses.contains(char);
      final isWrong = isGuessed && !normalizedWord.contains(char);
      final isCorrect = isGuessed && normalizedWord.contains(char);

      Color bgColor = Colors.white;
      Color textColor = AppColors.textPrimary;
      Color borderColor = AppColors.surfaceBorderDark;
      bool hasStrike = false;

      if (isCorrect) {
        bgColor = AppColors.warmAmberBg;
        textColor = AppColors.warmAmber;
        borderColor = AppColors.warmAmberBorder;
      } else if (isWrong) {
        bgColor = AppColors.surfaceElevated;
        textColor = AppColors.textMuted;
        borderColor = AppColors.surfaceBorder;
        hasStrike = true;
      }

      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5, vertical: 2),
          child: SizedBox(
            height: 38,
            child: Material(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
              elevation: 0,
              child: InkWell(
                onTap: (isGuessed || isOver)
                    ? null
                    : () => widget.onGuessLetter(char),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: borderColor, width: 1.2),
                  ),
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        char,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      if (hasStrike)
                        Positioned(
                          left: 4,
                          right: 4,
                          child: Container(
                            height: 1.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: row0.map(buildKey).toList()),
          Row(children: row1.map(buildKey).toList()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: row2.map(buildKey).toList()),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(children: row3.map(buildKey).toList()),
          ),
        ],
      ),
    );
  }

  /// Clues Modal dialog
  Widget _buildCluesDialog(HangmanState state) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${state.settingTeamName}'s Clues",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: _handleCloseClues,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                '• Note: Viewing clues reduces win reward from +2 pts to +1 pt.',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(height: 14),
              if (state.clues.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'No clues were provided for this word.',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              else
                ...List.generate(state.clues.length, (idx) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Text(
                        '${idx + 1}. ${state.clues[idx]}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: _handleCloseClues,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back to Arena',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Outcome Dialog with rubber stamp (NO EMOJIS!)
  Widget _buildOutcomeDialog(HangmanState state, RoundScoreResult outcome) {
    final isGuessed = outcome.reason != RoundOutcomeReason.strikesExpired;
    final stampText = isGuessed ? '[ WORD GUESSED ]' : '[ HANGMAN EXPIRED ]';
    final winningTeamName = outcome.winner == HangmanTeamRole.teamA
        ? state.teamAName
        : state.teamBName;

    String reasonDetail = '';
    if (outcome.reason == RoundOutcomeReason.guessedWithoutClues) {
      reasonDetail = 'Bonus: Solved without viewing clues (+2 Pts)!';
    } else if (outcome.reason == RoundOutcomeReason.guessedWithClues) {
      reasonDetail = 'Solved with clues opened (+1 Pt)';
    } else {
      reasonDetail = '7 strikes exhausted! Setting team earns +1 Pt';
    }

    return Container(
      color: Colors.black.withOpacity(0.55),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.surfaceBorder, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Monospace Retro Rubber Stamp (Strictly NO EMOJIS)
              Transform.rotate(
                angle: -0.05,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isGuessed ? AppColors.warmAmber : AppColors.imposterRed,
                      width: 2.2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    stampText,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: isGuessed ? AppColors.warmAmber : AppColors.imposterRed,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'THE SECRET WORD WAS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                normalizeWord(state.secretWord),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),

              // Score Breakdown Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$winningTeamName Wins Round',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: Text(
                            '+${outcome.pointsAwarded} PTS',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.warmAmber,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reasonDetail,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.only(top: 8),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.surfaceBorder),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Session Score:',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${state.teamAName} ${outcome.updatedScoreTeamA} — ${outcome.updatedScoreTeamB} ${state.teamBName}',
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Swap Roles & Next Round CTA (10% #A55704 Warm Amber Accent)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: widget.onNextRound,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warmAmber,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Swap Roles & Next Round →',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Back to Game Hub
              SizedBox(
                width: double.infinity,
                height: 42,
                child: TextButton(
                  onPressed: widget.onBackToHub,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                  child: const Text(
                    'Back to Game Hub',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

