import 'dart:math';
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../models/role.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_button.dart';

class DealCardsScreen extends StatefulWidget {
  final List<PlayerAssignment> assignments;
  final int currentCardIndex;
  final VoidCallback onNextPlayer;
  final VoidCallback onFinishDealing;

  const DealCardsScreen({
    super.key,
    required this.assignments,
    required this.currentCardIndex,
    required this.onNextPlayer,
    required this.onFinishDealing,
  });

  @override
  State<DealCardsScreen> createState() => _DealCardsScreenState();
}

class _DealCardsScreenState extends State<DealCardsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;
  bool _hasViewed = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _animation = Tween<double>(begin: 0, end: pi).animate(_animController);
  }

  @override
  void didUpdateWidget(covariant DealCardsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentCardIndex != widget.currentCardIndex) {
      _animController.reset();
      setState(() {
        _hasViewed = false;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onHoldDown() {
    setState(() {
      _hasViewed = true;
    });
    _animController.forward();
  }

  void _onHoldUp() {
    _animController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentCardIndex >= widget.assignments.length) {
      return const SizedBox.shrink();
    }

    final currentAssignment = widget.assignments[widget.currentCardIndex];
    final isLastPlayer = widget.currentCardIndex >= widget.assignments.length - 1;
    final role = currentAssignment.role;
    final isImposter = role is ImposterRole;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Header progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Player ${widget.currentCardIndex + 1} of ${widget.assignments.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Text(
                    'Secret Pass',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Card Area
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTapDown: (_) => _onHoldDown(),
                    onTapUp: (_) => _onHoldUp(),
                    onTapCancel: () => _onHoldUp(),
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        final angle = _animation.value;
                        final isFront = angle < (pi / 2);

                        return Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(angle),
                          alignment: Alignment.center,
                          child: isFront
                              ? _buildFrontCard(currentAssignment.playerName)
                              : Transform(
                                  transform: Matrix4.identity()..rotateY(pi),
                                  alignment: Alignment.center,
                                  child: _buildBackCard(role, isImposter),
                                ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Footer Button
              PrimaryButton(
                title: isLastPlayer ? 'Start Discussion' : 'Pass to Next Player',
                disabled: !_hasViewed,
                onPress: () {
                  if (isLastPlayer) {
                    widget.onFinishDealing();
                  } else {
                    widget.onNextPlayer();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard(String playerName) {
    return Container(
      width: 300,
      height: 420,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: const Text(
              'PASS DEVICE TO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            playerName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 36),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app, size: 18, color: AppColors.textOnPrimary),
                SizedBox(width: 8),
                Text(
                  'Hold to Reveal',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(PlayerRole role, bool isImposter) {
    return Container(
      width: 300,
      height: 420,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isImposter ? AppColors.imposterRed : AppColors.movieBlue,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isImposter ? AppColors.imposterRed : AppColors.movieBlue).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isImposter ? AppColors.imposterRedBg : AppColors.movieBlueBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isImposter
                  ? 'YOUR ROLE'
                  : ((role is NormalPlayerRole && role.industry == Industry.cartoons)
                      ? 'THE CARTOON'
                      : ((role is NormalPlayerRole && role.industry == Industry.kdrama)
                          ? 'THE K-DRAMA'
                          : ((role is NormalPlayerRole && role.industry == Industry.shows)
                              ? 'THE SHOW'
                              : 'THE MOVIE'))),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isImposter ? AppColors.imposterRed : AppColors.movieBlue,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (isImposter) ...[
            const Text(
              'IMPOSTER',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: AppColors.imposterRed,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            if (role is ImposterRole && role.revealedMovieTitle != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.flameOrangeBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.flameOrange, width: 1.5),
                ),
                child: Column(
                  children: [
                    const Text(
                      'TITLE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.flameOrangeDark,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      role.revealedMovieTitle!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (role is ImposterRole && role.clueText != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  children: [
                    const Text(
                      'YOUR SECRET CLUE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      role.clueText!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ] else ...[
            Text(
              (role as NormalPlayerRole).movieTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              role.industry.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
