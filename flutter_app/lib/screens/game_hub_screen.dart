import 'package:flutter/material.dart';
import '../services/update_service.dart';
import '../theme/app_colors.dart';

class GameHubScreen extends StatelessWidget {
  final VoidCallback onPlayImposter;
  final VoidCallback onPlayHangman;

  const GameHubScreen({
    super.key,
    required this.onPlayImposter,
    required this.onPlayHangman,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // Top Bar with Version Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Party Arcade',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  ValueListenableBuilder<UpdateInfo?>(
                    valueListenable: UpdateService.availableUpdateNotifier,
                    builder: (context, update, _) {
                      final hasUpdate = update != null;
                      return InkWell(
                        onTap: () {
                          if (hasUpdate) {
                            UpdateService.showUpdateDialog(context, update);
                          } else {
                            UpdateService.checkAndShowUpdateDialog(
                              context,
                              showNoUpdateMessage: true,
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: hasUpdate
                                ? AppColors.imposterRedBg
                                : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: hasUpdate
                                  ? AppColors.imposterRed.withOpacity(0.4)
                                  : AppColors.surfaceBorder,
                            ),
                          ),
                          child: Text(
                            hasUpdate
                                ? 'Update v${update.version}'
                                : 'v${UpdateService.currentAppVersion}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: hasUpdate
                                  ? AppColors.imposterRed
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // User specified tagline: strictly "Choose an offline party game to play with friends."
              const Text(
                'Choose an offline party game to play with friends.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Game Cards List
              Expanded(
                child: ListView(
                  children: [
                    // Game Card 1: Movie Imposter
                    _buildGameCard(
                      context: context,
                      icon: Icons.psychology_outlined,
                      title: 'Movie Imposter',
                      badge: '3–10+ Players',
                      badgeColor: AppColors.textSecondary,
                      badgeBg: AppColors.surfaceElevated,
                      description:
                          'Secret word bluffing & pass-and-play trivia deduction. Spot the imposter before time runs out!',
                      buttonText: 'Play Imposter',
                      buttonColor: AppColors.primary,
                      onTap: onPlayImposter,
                    ),
                    const SizedBox(height: 16),

                    // Game Card 2: Hangman Battle (10% #A55704 Warm Amber Accent)
                    _buildGameCard(
                      context: context,
                      icon: Icons.sports_kabaddi_outlined,
                      title: 'Hangman Battle',
                      badge: '2 Teams • New',
                      badgeColor: AppColors.warmAmber,
                      badgeBg: AppColors.warmAmberBg,
                      badgeBorder: AppColors.warmAmberBorder,
                      description:
                          'Pass-and-play word duel with strike tracker and optional hints. Deduce without clues for +2 Points!',
                      buttonText: 'Start Hangman',
                      buttonColor: AppColors.warmAmber,
                      onTap: onPlayHangman,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
  }

  Widget _buildGameCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String badge,
    required Color badgeColor,
    required Color badgeBg,
    Color? badgeBorder,
    required String description,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon & Badge Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Icon(icon, color: AppColors.textPrimary, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                  border: badgeBorder != null
                      ? Border.all(color: badgeBorder)
                      : null,
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
