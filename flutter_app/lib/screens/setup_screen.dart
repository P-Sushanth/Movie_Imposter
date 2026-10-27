import 'package:flutter/material.dart';
import '../domain/validation.dart';
import '../models/movie.dart';
import '../models/player_group.dart';
import '../services/update_service.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_button.dart';

class SetupScreen extends StatelessWidget {
  final List<Industry> selectedIndustries;
  final void Function(Industry) onToggleIndustry;
  final VoidCallback onSelectAllIndustries;
  final List<String> players;
  final List<String> playerKeys;
  final void Function(int index, String name) onChangePlayer;
  final VoidCallback onAddPlayer;
  final void Function(int index) onRemovePlayer;
  final void Function(int oldIndex, int newIndex) onReorderPlayer;
  final List<PlayerGroup> savedGroups;
  final String? selectedGroupId;
  final void Function(PlayerGroup group)? onSelectGroup;
  final void Function(String name)? onCreateGroup;
  final void Function(String groupId, String newName)? onRenameGroup;
  final void Function(PlayerGroup group)? onUpdateGroup;
  final void Function(String groupId)? onDeleteGroup;
  final VoidCallback? onClearGroup;
  final int numImposters;
  final void Function(int count) onChangeNumImposters;
  final bool imposterClueEnabled;
  final void Function(bool enabled) onToggleClueEnabled;
  final bool revealNameToImposter;
  final void Function(bool enabled) onToggleRevealNameToImposter;
  final int discussionTimerMinutes;
  final void Function(int minutes) onChangeDiscussionTimer;
  final VoidCallback onStartGame;
  const SetupScreen({
    super.key,
    required this.selectedIndustries,
    required this.onToggleIndustry,
    required this.onSelectAllIndustries,
    required this.players,
    this.playerKeys = const [],
    required this.onChangePlayer,
    required this.onAddPlayer,
    required this.onRemovePlayer,
    required this.onReorderPlayer,
    this.savedGroups = const [],
    this.selectedGroupId,
    this.onSelectGroup,
    this.onCreateGroup,
    this.onRenameGroup,
    this.onUpdateGroup,
    this.onDeleteGroup,
    this.onClearGroup,
    required this.numImposters,
    required this.onChangeNumImposters,
    required this.imposterClueEnabled,
    required this.onToggleClueEnabled,
    required this.revealNameToImposter,
    required this.onToggleRevealNameToImposter,
    this.discussionTimerMinutes = 0,
    required this.onChangeDiscussionTimer,
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
                        ValueListenableBuilder<UpdateInfo?>(
                          valueListenable: UpdateService.availableUpdateNotifier,
                          builder: (context, update, _) {
                            final hasUpdate = update != null;
                            return InkWell(
                              onTap: () {
                                if (hasUpdate) {
                                  UpdateService.showUpdateDialog(context, update);
                                } else {
                                  UpdateService.checkAndShowUpdateDialog(context, showNoUpdateMessage: true);
                                }
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: hasUpdate ? AppColors.imposterRedBg : AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: hasUpdate ? AppColors.imposterRed.withOpacity(0.4) : AppColors.surfaceBorder,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (hasUpdate) ...[
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: const BoxDecoration(
                                          color: AppColors.imposterRed,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                    ],
                                    Text(
                                      hasUpdate ? 'Update ${update.version}' : 'v${UpdateService.currentAppVersion}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: hasUpdate ? AppColors.imposterRed : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    // Update Available Notification Banner (if update is ready)
                    ValueListenableBuilder<UpdateInfo?>(
                      valueListenable: UpdateService.availableUpdateNotifier,
                      builder: (context, update, _) {
                        if (update == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => UpdateService.showUpdateDialog(context, update),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.08),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.auto_awesome,
                                        color: AppColors.primary,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Text(
                                                'New Update Available',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  update.version,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.textOnPrimary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'Tap to view new features and update now',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                      color: AppColors.textMuted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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

                    // 2. Spice It Up Section (Flame Orange)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.flameOrangeBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.flameOrange, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.flameOrange.withOpacity(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.flameOrange.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.local_fire_department_rounded,
                                  color: AppColors.flameOrange,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Spice It Up',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.flameOrangeDark,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(color: AppColors.flameOrangeBorder.withOpacity(0.7), height: 1),
                          const SizedBox(height: 14),

                          // Option 1: Number of Imposters
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Number of Imposters',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Max $maxImposters for ${players.length} players',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                                    width: 44,
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$numImposters',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.flameOrangeDark,
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
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Divider(color: AppColors.flameOrangeBorder.withOpacity(0.7), height: 1),
                          const SizedBox(height: 14),

                          // Option 2: Discussion Timer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Discussion Timer',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      discussionTimerMinutes == 0
                                          ? '0 min (No Limit)'
                                          : '$discussionTimerMinutes min${discussionTimerMinutes > 1 ? "s" : ""} countdown',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  _buildStepperButton(
                                    icon: Icons.remove_rounded,
                                    enabled: discussionTimerMinutes > 0,
                                    onTap: () {
                                      if (discussionTimerMinutes > 0) {
                                        onChangeDiscussionTimer(discussionTimerMinutes - 1);
                                      }
                                    },
                                  ),
                                  Container(
                                    width: 44,
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$discussionTimerMinutes',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.flameOrangeDark,
                                      ),
                                    ),
                                  ),
                                  _buildStepperButton(
                                    icon: Icons.add_rounded,
                                    enabled: discussionTimerMinutes < 10,
                                    onTap: () {
                                      if (discussionTimerMinutes < 10) {
                                        onChangeDiscussionTimer(discussionTimerMinutes + 1);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Divider(color: AppColors.flameOrangeBorder.withOpacity(0.7), height: 1),
                          const SizedBox(height: 14),

                          // Option 3: Give hint to imposter
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Give hint to imposter',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Switch(
                                value: imposterClueEnabled,
                                onChanged: onToggleClueEnabled,
                                activeColor: AppColors.flameOrange,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Divider(color: AppColors.flameOrangeBorder.withOpacity(0.7), height: 1),
                          const SizedBox(height: 14),

                          // Option 3: Reveal Name to Imposter
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Reveal Name to Imposter',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Switch(
                                value: revealNameToImposter,
                                onChanged: onToggleRevealNameToImposter,
                                activeColor: AppColors.flameOrange,
                              ),
                            ],
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
                              InkWell(
                                onTap: () => _showSaveGroupDialog(context),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.surfaceBorder),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.bookmark_add_outlined, size: 14, color: AppColors.primary),
                                      SizedBox(width: 4),
                                      Text(
                                        'Save as Group',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (savedGroups.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: savedGroups.map((group) {
                                  final isSelected = selectedGroupId == group.id;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: InkWell(
                                      onTap: () {
                                        if (isSelected) {
                                          onClearGroup?.call();
                                        } else {
                                          onSelectGroup?.call(group);
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppColors.primary : AppColors.surfaceElevated,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isSelected ? Icons.group_rounded : Icons.group_outlined,
                                              size: 13,
                                              color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              group.name,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '(${group.players.length})',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isSelected ? AppColors.textOnPrimary.withValues(alpha: 0.8) : AppColors.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                          if (selectedGroupId != null) ...[
                            () {
                              final groupIndex = savedGroups.indexWhere((g) => g.id == selectedGroupId);
                              if (groupIndex == -1) return const SizedBox.shrink();
                              final group = savedGroups[groupIndex];
                              return Container(
                                margin: const EdgeInsets.only(top: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.surfaceBorder),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, size: 15, color: AppColors.primary),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Group: ${group.name}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
                                      onPressed: () => _showRenameGroupDialog(context, group),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                      splashRadius: 14,
                                      tooltip: 'Rename Group',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.save_outlined, size: 16, color: AppColors.textSecondary),
                                      onPressed: () {
                                        final validPlayers = players.map((p) => p.trim()).toList();
                                        onUpdateGroup?.call(group.copyWith(players: validPlayers));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Saved current players to "${group.name}"!'),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                      splashRadius: 14,
                                      tooltip: 'Update Group with current players',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.danger),
                                      onPressed: () => _confirmDeleteGroup(context, group),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                      splashRadius: 14,
                                      tooltip: 'Delete Group',
                                    ),
                                  ],
                                ),
                              );
                            }(),
                          ],
                          const SizedBox(height: 12),
                          ReorderableListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            buildDefaultDragHandles: false,
                            itemCount: players.length,
                            onReorder: onReorderPlayer,
                            proxyDecorator: (Widget child, int index, Animation<double> animation) {
                              return Material(
                                color: Colors.transparent,
                                elevation: 6,
                                shadowColor: Colors.black26,
                                borderRadius: BorderRadius.circular(8),
                                child: child,
                              );
                            },
                            itemBuilder: (context, index) {
                              final name = players[index];
                              final keyStr = index < playerKeys.length ? playerKeys[index] : 'player_key_$index';
                              return _PlayerInputItem(
                                key: ValueKey(keyStr),
                                index: index,
                                name: name,
                                onChanged: (text) => onChangePlayer(index, text),
                                onRemove: canRemovePlayer ? () => onRemovePlayer(index) : null,
                              );
                            },
                          ),
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

  void _showSaveGroupDialog(BuildContext context) {
    final validPlayers = resolvePlayerNames(players);
    if (validPlayers.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please have at least 3 players before saving a group.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final controller = TextEditingController(text: 'Group ${savedGroups.length + 1}');
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
              child: const Icon(Icons.bookmark_add_outlined, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Save as Group',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter a name for this group of players:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              maxLength: 24,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. Movie Squad',
                counterText: '',
                filled: true,
                fillColor: AppColors.surfaceElevated,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
            const SizedBox(height: 8),
            Text(
              'Players: ${validPlayers.join(", ")}',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.surfaceBorderDark),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(ctx);
                onCreateGroup?.call(name);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Save Group', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showRenameGroupDialog(BuildContext context, PlayerGroup group) {
    final controller = TextEditingController(text: group.name);
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
              child: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Rename Group',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 24,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Group Name',
            counterText: '',
            filled: true,
            fillColor: AppColors.surfaceElevated,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.surfaceBorderDark),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(ctx);
                onRenameGroup?.call(group.id, name);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteGroup(BuildContext context, PlayerGroup group) {
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
              child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Delete "${group.name}"?',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'This group will be removed from your saved groups.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.surfaceBorderDark),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDeleteGroup?.call(group.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerInputItem extends StatefulWidget {
  final int index;
  final String name;
  final ValueChanged<String> onChanged;
  final VoidCallback? onRemove;

  const _PlayerInputItem({
    super.key,
    required this.index,
    required this.name,
    required this.onChanged,
    this.onRemove,
  });

  @override
  State<_PlayerInputItem> createState() => _PlayerInputItemState();
}

class _PlayerInputItemState extends State<_PlayerInputItem> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.name);
  }

  @override
  void didUpdateWidget(covariant _PlayerInputItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.name != _controller.text) {
      _controller.text = widget.name;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: widget.index,
            child: Container(
              width: 34,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Text(
                '${widget.index + 1}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              maxLength: 24,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: 'Player ${widget.index + 1}',
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
          const SizedBox(width: 6),
          ReorderableDragStartListener(
            index: widget.index,
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: Container(
                width: 34,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: const Icon(
                  Icons.unfold_more_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          if (widget.onRemove != null) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline_rounded, size: 20, color: AppColors.danger),
              onPressed: widget.onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 26, minHeight: 28),
              splashRadius: 16,
              tooltip: 'Remove player',
            ),
          ],
        ],
      ),
    );
  }
}
