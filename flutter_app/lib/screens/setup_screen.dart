import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/update_service.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_button.dart';

class SetupScreen extends StatelessWidget {
  final List<Industry> selectedIndustries;
  final void Function(Industry) onToggleIndustry;
  final VoidCallback onSelectAllIndustries;
  final List<String> players;
  final void Function(int index, String name) onChangePlayer;
  final VoidCallback onAddPlayer;
  final void Function(int index) onRemovePlayer;
  final int numImposters;
  final void Function(int count) onChangeNumImposters;
  final bool imposterClueEnabled;
  final void Function(bool enabled) onToggleClueEnabled;
  final VoidCallback onStartGame;
  final int sessionMovieCount;
  final VoidCallback? onResetSession;

  const SetupScreen({
    super.key,
    required this.selectedIndustries,
    required this.onToggleIndustry,
    required this.onSelectAllIndustries,
    required this.players,
    required this.onChangePlayer,
    required this.onAddPlayer,
    required this.onRemovePlayer,
    required this.numImposters,
    required this.onChangeNumImposters,
    required this.imposterClueEnabled,
    required this.onToggleClueEnabled,
    required this.onStartGame,
    this.sessionMovieCount = 0,
    this.onResetSession,
  });

  @override
  Widget build(BuildContext context) {
    final maxImposters = (players.length ~/ 2).clamp(1, 5);
    final canAddMorePlayers = players.length < 10;
    final canRemovePlayer = players.length > 3;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Version Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Movie Imposter',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            UpdateService.checkAndShowUpdateDialog(context, showNoUpdateMessage: true);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceBorder.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'v$kCurrentAppVersion',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (sessionMovieCount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.surfaceBorder),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.movie_filter_outlined, size: 13, color: AppColors.textMuted),
                                const SizedBox(width: 5),
                                Text(
                                  '$sessionMovieCount movie${sessionMovieCount == 1 ? '' : 's'} played this session',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (onResetSession != null)
                            InkWell(
                              onTap: onResetSession,
                              borderRadius: BorderRadius.circular(6),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                child: Text(
                                  'Reset',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.danger,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),

                    // 1. Categories Section
                    _buildCardSection(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Categories',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              GestureDetector(
                                onTap: onSelectAllIndustries,
                                child: const Text(
                                  'Select All',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: Industry.values.map((industry) {
                              final isSelected = selectedIndustries.contains(industry);
                              return InkWell(
                                onTap: () => onToggleIndustry(industry),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary : AppColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
                                    ),
                                  ),
                                  child: Text(
                                    industry.label,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. Number of Imposters Section
                    _buildCardSection(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Number of Imposters',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildStepperButton(
                                icon: Icons.remove,
                                enabled: numImposters > 1,
                                onTap: () {
                                  if (numImposters > 1) {
                                    onChangeNumImposters(numImposters - 1);
                                  }
                                },
                              ),
                              Container(
                                width: 56,
                                alignment: Alignment.center,
                                child: Text(
                                  '$numImposters',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              _buildStepperButton(
                                icon: Icons.add,
                                enabled: numImposters < maxImposters,
                                onTap: () {
                                  if (numImposters < maxImposters) {
                                    onChangeNumImposters(numImposters + 1);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. Imposter Hint Section
                    _buildCardSection(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Imposter Hint',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  imposterClueEnabled
                                      ? 'Enabled — Imposter gets a subtle clue'
                                      : 'Disabled — Imposter gets no clues',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: imposterClueEnabled,
                            onChanged: onToggleClueEnabled,
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4. Players Section
                    _buildCardSection(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Players (${players.length})',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Text(
                                'Leave blank for default',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...players.asMap().entries.map((entry) {
                            final index = entry.key;
                            final name = entry.value;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceElevated,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.surfaceBorder),
                                    ),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: name,
                                      onChanged: (text) => onChangePlayer(index, text),
                                      maxLength: 20,
                                      decoration: InputDecoration(
                                        counterText: '',
                                        hintText: 'Player ${index + 1}',
                                        hintStyle: const TextStyle(color: AppColors.textMuted),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        filled: true,
                                        fillColor: AppColors.surfaceElevated,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: AppColors.surfaceBorder),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: AppColors.surfaceBorder),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (canRemovePlayer) ...[
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 20, color: AppColors.danger),
                                      onPressed: () => onRemovePlayer(index),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),
                          if (canAddMorePlayers) ...[
                            const SizedBox(height: 6),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: onAddPlayer,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: const BorderSide(color: AppColors.surfaceBorderDark),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  '+ Add Player',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Start Game Action
            Padding(
              padding: const EdgeInsets.all(20),
              child: PrimaryButton(
                title: 'Start Game',
                onPress: onStartGame,
                disabled: selectedIndustries.isEmpty,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSection({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: child,
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? AppColors.surfaceElevated : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppColors.textPrimary : AppColors.textMuted,
        ),
      ),
    );
  }
}
