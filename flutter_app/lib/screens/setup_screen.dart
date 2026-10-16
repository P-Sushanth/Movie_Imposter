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
  });

  @override
  Widget build(BuildContext context) {
    final maxImposters = (players.length ~/ 2).clamp(1, 9999);
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
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            UpdateService.checkAndShowUpdateDialog(context, showNoUpdateMessage: true);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.surfaceBorder),
                            ),
                            child: const Text(
                              'v$kCurrentAppVersion',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                              InkWell(
                                onTap: onSelectAllIndustries,
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.surfaceBorder),
                                  ),
                                  child: const Text(
                                    'Select All',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: Industry.values.map((industry) {
                              final isSelected = selectedIndustries.contains(industry);
                              return InkWell(
                                onTap: () => onToggleIndustry(industry),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary : AppColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                        size: 16,
                                        color: isSelected ? AppColors.textOnPrimary : AppColors.textMuted,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        industry.label,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Number of Imposters',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${players.length - numImposters} innocents • $numImposters imposter${numImposters > 1 ? 's' : ''}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              _buildStepperButton(
                                icon: Icons.remove_rounded,
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
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              _buildStepperButton(
                                icon: Icons.add_rounded,
                                enabled: numImposters < maxImposters,
                                onTap: () {
                                  if (numImposters < maxImposters) {
                                    onChangeNumImposters(numImposters + 1);
                                  }
                                },
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  numImposters == 1
                                      ? '1 player will receive a fake or clue role.'
                                      : '$numImposters players will receive fake roles.',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    height: 1.3,
                                  ),
                                ),
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
                                      ? 'Enabled — Imposter gets a subtle clue (decade, genre...)'
                                      : 'Disabled — Imposter gets no clues at all',
                                  style: const TextStyle(
                                    fontSize: 12,
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
                                '3 minimum • No limit',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ...players.asMap().entries.map((entry) {
                            final index = entry.key;
                            final name = entry.value;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 38,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceElevated,
                                      borderRadius: BorderRadius.circular(8),
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
                                      maxLength: 24,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: InputDecoration(
                                        counterText: '',
                                        hintText: 'Player ${index + 1}',
                                        hintStyle: const TextStyle(color: AppColors.textMuted),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                                    const SizedBox(width: 6),
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline_rounded, size: 22, color: AppColors.danger),
                                      onPressed: () => onRemovePlayer(index),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      splashRadius: 20,
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: onAddPlayer,
                              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                              label: Text(
                                'Add Player (${players.length + 1})',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.surfaceBorderDark, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
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
