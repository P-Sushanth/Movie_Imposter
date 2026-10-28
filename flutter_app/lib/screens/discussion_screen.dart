import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/movie.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_button.dart';

class DiscussionScreen extends StatefulWidget {
  final String movieTitle;
  final List<String> imposters;
  final String startingPlayer;
  final VoidCallback onReturnToSetup;
  final VoidCallback onNextRound;
  final int discussionTimerMinutes;
  final Industry? industry;

  const DiscussionScreen({
    super.key,
    required this.movieTitle,
    required this.imposters,
    required this.startingPlayer,
    required this.onReturnToSetup,
    required this.onNextRound,
    this.discussionTimerMinutes = 0,
    this.industry,
  });

  @override
  State<DiscussionScreen> createState() => _DiscussionScreenState();
}

class _DiscussionScreenState extends State<DiscussionScreen> {
  bool _isRevealed = false;
  Timer? _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    if (widget.discussionTimerMinutes > 0) {
      _remainingSeconds = widget.discussionTimerMinutes * 60;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        if (_remainingSeconds == 0) {
          timer.cancel();
          _triggerTimesUpVibration();
        }
      } else {
        timer.cancel();
      }
    });
  }

  static const MethodChannel _nativeChannel = MethodChannel('com.imposterwho.game/updater');

  void _triggerTimesUpVibration() {
    try {
      // High-intensity repeating hardware vibration pattern on Android:
      // 500ms buzz, 150ms pause, 500ms buzz, 150ms pause, 800ms buzz at max amplitude
      _nativeChannel.invokeMethod('vibrateAlert').catchError((_) => null);
    } catch (_) {}

    try {
      HapticFeedback.heavyImpact();
      HapticFeedback.vibrate();
    } catch (_) {}
  }

  void _stopTimesUpVibration() {
    try {
      _nativeChannel.invokeMethod('cancelVibration').catchError((_) => null);
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopTimesUpVibration();
    super.dispose();
  }

  String _formatTimerDisplay(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color _getTimerTextColor() {
    if (_remainingSeconds == 0) {
      return const Color(0xFFFF0000); // Pure Red
    }
    if (_remainingSeconds <= 5) {
      final t = (5 - _remainingSeconds) / 5.0;
      return Color.lerp(const Color(0xFF1E0000), const Color(0xFFFF0000), t)!;
    }
    if (_remainingSeconds <= 30) {
      return AppColors.flameOrangeDark;
    }
    return AppColors.textPrimary;
  }

  Color _getTimerLabelColor() {
    if (_remainingSeconds == 0) {
      return const Color(0xFFFF0000); // Pure Red
    }
    if (_remainingSeconds <= 5) {
      final t = (5 - _remainingSeconds) / 5.0;
      return Color.lerp(const Color(0xFF1E0000), const Color(0xFFFF0000), t)!;
    }
    if (_remainingSeconds <= 30) {
      return AppColors.flameOrangeDark;
    }
    return AppColors.textSecondary;
  }

  Color _getTimerBorderColor() {
    if (_remainingSeconds == 0) {
      return const Color(0xFFFF0000); // Pure Red
    }
    if (_remainingSeconds <= 5) {
      final t = (5 - _remainingSeconds) / 5.0;
      return Color.lerp(const Color(0xFF3A0808), const Color(0xFFFF0000), t)!;
    }
    if (_remainingSeconds <= 30) {
      return AppColors.flameOrange;
    }
    return AppColors.surfaceBorder;
  }

  Color _getTimerBgColor() {
    if (_remainingSeconds == 0) {
      return const Color(0xFFFFEAEA);
    }
    if (_remainingSeconds <= 5) {
      final t = (5 - _remainingSeconds) / 5.0;
      return Color.lerp(const Color(0xFFFFF7F2), const Color(0xFFFFEAEA), t)!;
    }
    if (_remainingSeconds <= 30) {
      return AppColors.flameOrangeBg;
    }
    return AppColors.surface;
  }

  void _handleNextRoundClick() {
    _stopTimesUpVibration();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceBorder, width: 1.5),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.replay_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Start Next Round?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to start the next round? The phone will be passed around from the first player again with a new name and the same imposter.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.surfaceBorderDark),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onNextRound();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Next Round', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _handleRevealClick() {
    _stopTimesUpVibration();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceBorder, width: 1.5),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.visibility_rounded, color: AppColors.danger, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Reveal Imposter?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to end the discussion and reveal the imposter?',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.surfaceBorderDark),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _timer?.cancel();
              setState(() {
                _isRevealed = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.textOnPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Yes, Reveal', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: !_isRevealed
                      ? SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10),
                              const Text(
                                'Discussion Time',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  widget.industry == Industry.cartoons
                                      ? 'Discuss the cartoon, ask questions, and find the imposter.'
                                      : (widget.industry == Industry.kdrama
                                          ? 'Discuss the K-drama, ask questions, and find the imposter.'
                                          : (widget.industry == Industry.shows
                                              ? 'Discuss the show, ask questions, and find the imposter.'
                                              : 'Discuss the movie, ask questions, and find the imposter.')),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Starting Player Spotlight Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.surfaceBorder, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'STARTS THE ROUND',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primary,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      widget.startingPlayer,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textPrimary,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (widget.discussionTimerMinutes > 0) ...[
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: _getTimerBgColor(),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _getTimerBorderColor(),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.timer_outlined,
                                            size: 16,
                                            color: _getTimerLabelColor(),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _remainingSeconds == 0
                                                ? "TIME'S UP! VOTE NOW"
                                                : 'DISCUSSION TIME REMAINING',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: _getTimerLabelColor(),
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _formatTimerDisplay(_remainingSeconds),
                                        style: TextStyle(
                                          fontSize: 38,
                                          fontWeight: FontWeight.w900,
                                          color: _getTimerTextColor(),
                                          letterSpacing: 1.5,
                                          fontFamily: 'Courier New',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                            ],
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.surfaceBorderDark, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.imposters.length > 1 ? 'THE IMPOSTERS WERE' : 'THE IMPOSTER WAS',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.imposterRed,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.imposters.join(', '),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.imposterRed,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                width: 60,
                                height: 1.5,
                                color: AppColors.surfaceBorderDark,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                widget.industry == Industry.cartoons
                                    ? 'THE CARTOON'
                                    : (widget.industry == Industry.kdrama
                                        ? 'THE K-DRAMA'
                                        : (widget.industry == Industry.shows ? 'THE SHOW' : 'THE MOVIE')),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.movieTitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),

              // Action Buttons
              if (!_isRevealed) ...[
                PrimaryButton(
                  title: 'Next Round',
                  variant: ButtonVariant.primary,
                  onPress: _handleNextRoundClick,
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  title: 'Reveal Imposter',
                  variant: ButtonVariant.danger,
                  onPress: _handleRevealClick,
                ),
              ] else
                PrimaryButton(
                  title: 'Back to Setup',
                  variant: ButtonVariant.primary,
                  onPress: widget.onReturnToSetup,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
