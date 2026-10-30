import 'package:flutter/material.dart';
import '../domain/hangman.dart';
import '../theme/app_colors.dart';

class HangmanWordEntryScreen extends StatefulWidget {
  final HangmanState state;
  final VoidCallback onBackToTeamSetup;
  final void Function({
    required String secretWord,
    required List<String> clues,
  }) onLockWordAndPass;

  const HangmanWordEntryScreen({
    super.key,
    required this.state,
    required this.onBackToTeamSetup,
    required this.onLockWordAndPass,
  });

  @override
  State<HangmanWordEntryScreen> createState() => _HangmanWordEntryScreenState();
}

class _HangmanWordEntryScreenState extends State<HangmanWordEntryScreen> {
  late final TextEditingController _secretWordController;
  late final TextEditingController _clue1Controller;
  late final TextEditingController _clue2Controller;
  late final TextEditingController _clue3Controller;

  bool _obscureSecretWord = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _secretWordController = TextEditingController(text: widget.state.secretWord);
    _clue1Controller = TextEditingController(
      text: widget.state.clues.isNotEmpty ? widget.state.clues[0] : '',
    );
    _clue2Controller = TextEditingController(
      text: widget.state.clues.length > 1 ? widget.state.clues[1] : '',
    );
    _clue3Controller = TextEditingController(
      text: widget.state.clues.length > 2 ? widget.state.clues[2] : '',
    );
  }

  @override
  void dispose() {
    _secretWordController.dispose();
    _clue1Controller.dispose();
    _clue2Controller.dispose();
    _clue3Controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final word = normalizeWord(_secretWordController.text);
    if (word.isEmpty) {
      setState(() {
        _validationError = 'Please enter a secret word, movie, or phrase.';
      });
      return;
    }

    bool hasAlphanumeric = false;
    for (int i = 0; i < word.length; i++) {
      if (isLetterOrDigit(word[i])) {
        hasAlphanumeric = true;
        break;
      }
    }

    if (!hasAlphanumeric) {
      setState(() {
        _validationError = 'Word must include at least one letter or digit.';
      });
      return;
    }

    final clues = <String>[];
    if (_clue1Controller.text.trim().isNotEmpty) {
      clues.add(_clue1Controller.text.trim());
    }
    if (_clue2Controller.text.trim().isNotEmpty) {
      clues.add(_clue2Controller.text.trim());
    }
    if (_clue3Controller.text.trim().isNotEmpty) {
      clues.add(_clue3Controller.text.trim());
    }

    widget.onLockWordAndPass(
      secretWord: word,
      clues: clues,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingTeamName = widget.state.settingTeamName;
    final guessingTeamName = widget.state.guessingTeamName;

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
                        onTap: widget.onBackToTeamSetup,
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
                        'Word Entry',
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
                        // Word Creator Spotlight Card (30% Ink Navy Hero with #A55704 Accent)
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'WORD CREATOR',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.warmAmber,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.warmAmber.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.warmAmber.withOpacity(0.4),
                                      ),
                                    ),
                                    child: const Text(
                                      'SETTING TURN',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.amberAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                settingTeamName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.only(top: 10),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Color(0xFF334155)),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Target for: $guessingTeamName',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Shield screen!',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white38,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Secret Word Hero Card (High Contrast)
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.primary, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'SECRET WORD *',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '$guessingTeamName Guesses This',
                                      textAlign: TextAlign.end,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: _secretWordController,
                                textCapitalization: TextCapitalization.characters,
                                obscureText: _obscureSecretWord,
                                onChanged: (_) {
                                  if (_validationError != null) {
                                    setState(() {
                                      _validationError = null;
                                    });
                                  }
                                },
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.0,
                                  color: AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'E.G. INTERSTELLAR',
                                  hintStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.0,
                                    color: AppColors.textMuted,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureSecretWord
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      size: 20,
                                      color: AppColors.textSecondary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureSecretWord = !_obscureSecretWord;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor: AppColors.background,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.surfaceBorder,
                                    ),
                                  ),
                                ),
                              ),
                              if (_validationError != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  _validationError!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.danger,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 6),
                              const Text(
                                'Spaces and punctuation are revealed automatically.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Optional Hints Card (Neutral Grouped Stone Surface)
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'OPTIONAL HINTS (UP TO 3)',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.surfaceBorder),
                                    ),
                                    child: const Text(
                                      'Max 3',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _buildClueField(controller: _clue1Controller, number: 1),
                              const SizedBox(height: 10),
                              _buildClueField(controller: _clue2Controller, number: 2),
                              const SizedBox(height: 10),
                              _buildClueField(controller: _clue3Controller, number: 3),
                              const SizedBox(height: 12),
                              const Text(
                                'Clues remain hidden. Guessing team can choose to view them during play.',
                                style: TextStyle(
                                  fontSize: 11,
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
                              'Lock Word & Pass Phone →',
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

  Widget _buildClueField({
    required TextEditingController controller,
    required int number,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Clue $number (Optional)',
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.surfaceBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.surfaceBorder),
              ),
            ),
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
