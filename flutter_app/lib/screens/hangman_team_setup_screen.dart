import 'package:flutter/material.dart';
import '../domain/hangman.dart';
import '../theme/app_colors.dart';

class HangmanTeamSetupScreen extends StatefulWidget {
  final HangmanState state;
  final VoidCallback onBackToHub;
  final void Function({
    required String teamAName,
    required String teamBName,
  }) onProceedToWordEntry;

  const HangmanTeamSetupScreen({
    super.key,
    required this.state,
    required this.onBackToHub,
    required this.onProceedToWordEntry,
  });

  @override
  State<HangmanTeamSetupScreen> createState() => _HangmanTeamSetupScreenState();
}

class _HangmanTeamSetupScreenState extends State<HangmanTeamSetupScreen> {
  late final TextEditingController _teamAController;
  late final TextEditingController _teamBController;

  @override
  void initState() {
    super.initState();
    _teamAController = TextEditingController(text: widget.state.teamAName);
    _teamBController = TextEditingController(text: widget.state.teamBName);
  }

  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final teamA = _teamAController.text.trim().isEmpty
        ? 'Team Popcorn'
        : _teamAController.text.trim();
    final teamB = _teamBController.text.trim().isEmpty
        ? 'Team Cinema'
        : _teamBController.text.trim();

    widget.onProceedToWordEntry(
      teamAName: teamA,
      teamBName: teamB,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                // Top Navigation Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: widget.onBackToHub,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Team Setup',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Session Scoreboard Card
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          child: Column(
                            children: [
                              const Text(
                                'SESSION SCOREBOARD',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textMuted,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        '${widget.state.scoreTeamA}',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        _teamAController.text.trim().isEmpty
                                            ? 'Team Popcorn'
                                            : _teamAController.text.trim(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Text(
                                    'VS',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.surfaceBorderDark,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '${widget.state.scoreTeamB}',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.warmAmber,
                                        ),
                                      ),
                                      Text(
                                        _teamBController.text.trim().isEmpty
                                            ? 'Team Cinema'
                                            : _teamBController.text.trim(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Team Names Inputs (60% White Card, 30% Stone Borders & Ink)
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
                          ),
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TEAM NAMES',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textMuted,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.state.settingTeam == HangmanTeamRole.teamA
                                        ? 'Team A Name (Setting Word)'
                                        : 'Team A Name (Guessing)',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _teamAController,
                                    onChanged: (_) => setState(() {}),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Team Popcorn',
                                      filled: true,
                                      fillColor: AppColors.background,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(color: AppColors.surfaceBorder),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.state.settingTeam == HangmanTeamRole.teamB
                                        ? 'Team B Name (Setting Word)'
                                        : 'Team B Name (Guessing)',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _teamBController,
                                    onChanged: (_) => setState(() {}),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Team Cinema',
                                      filled: true,
                                      fillColor: AppColors.background,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(color: AppColors.surfaceBorder),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Scoring Rules Notice (30% Soft Stone Neutral, Clean 1-Line Bullets)
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
                            children: const [
                              Text(
                                'Scoring Rules',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                '• Guess without clues: +2 Points',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                '• Guess with clues opened: +1 Point',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                '• 7 strikes hit: Setting team +1 Pt',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Primary CTA Button (10% #A55704 Warm Amber Accent)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.warmAmber,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Enter Secret Word →',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
