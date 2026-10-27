import 'dart:math';
import 'package:flutter/material.dart';
import 'data/movies_data.dart';
import 'domain/game_setup.dart';
import 'domain/validation.dart';
import 'models/movie.dart';
import 'models/player_group.dart';
import 'models/round_state.dart';
import 'screens/deal_cards_screen.dart';
import 'screens/discussion_screen.dart';
import 'screens/setup_screen.dart';
import 'services/group_service.dart';
import 'services/update_service.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UpdateService.initVersion();
  runApp(const MovieImposterApp());
}

class MovieImposterApp extends StatelessWidget {
  const MovieImposterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Imposter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const GameContainer(),
    );
  }
}

enum ScreenState {
  setup,
  dealing,
  discussion,
}

class GameContainer extends StatefulWidget {
  const GameContainer({super.key});

  @override
  State<GameContainer> createState() => _GameContainerState();
}

class _GameContainerState extends State<GameContainer> with WidgetsBindingObserver {
  ScreenState _currentScreen = ScreenState.setup;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSavedGroups();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService.checkAndShowUpdateDialog(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _currentScreen == ScreenState.setup) {
      UpdateService.checkAndShowUpdateDialog(context);
    }
  }

  // Setup state
  List<Industry> _selectedIndustries = [
    Industry.tollywood,
    Industry.bollywood,
    Industry.hollywood,
    Industry.shows,
    Industry.kdrama,
    Industry.cartoons,
  ];
  List<String> _players = ['', '', ''];
  final List<String> _playerKeys = ['p_0', 'p_1', 'p_2'];
  int _nextPlayerKeyId = 3;
  List<PlayerGroup> _savedGroups = [];
  String? _selectedGroupId;
  int _numImposters = 1;
  bool _imposterClueEnabled = true;
  bool _revealNameToImposter = false;
  int _discussionTimerMinutes = 0;

  // Active round state
  RoundState? _roundState;

  // Track movies played in this session only
  final Set<String> _usedMovieIds = <String>{};
  String? _previousClueKey;

  // Industry handlers
  void _handleToggleIndustry(Industry ind) {
    setState(() {
      if (_selectedIndustries.contains(ind)) {
        _selectedIndustries.remove(ind);
      } else {
        _selectedIndustries.add(ind);
      }
    });
  }

  void _handleSelectAllIndustries() {
    setState(() {
      _selectedIndustries = [
        Industry.tollywood,
        Industry.bollywood,
        Industry.hollywood,
        Industry.shows,
        Industry.kdrama,
        Industry.cartoons,
      ];
    });
  }

  // Player handlers
  void _handleChangePlayer(int index, String name) {
    _players[index] = name;
  }

  void _handleAddPlayer() {
    setState(() {
      _players.add('');
      _playerKeys.add('p_${_nextPlayerKeyId++}');
    });
  }

  void _handleRemovePlayer(int index) {
    if (_players.length > 3) {
      setState(() {
        _players.removeAt(index);
        _playerKeys.removeAt(index);
        final maxImposters = _players.length ~/ 2;
        if (_numImposters > maxImposters) {
          _numImposters = maxImposters.clamp(1, 9999);
        }
      });
    }
  }

  void _handleReorderPlayer(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final player = _players.removeAt(oldIndex);
      _players.insert(newIndex, player);
      final key = _playerKeys.removeAt(oldIndex);
      _playerKeys.insert(newIndex, key);
    });
  }

  // Group handlers
  Future<void> _loadSavedGroups() async {
    final groups = await GroupService.loadGroups();
    final lastSelectedId = await GroupService.loadLastSelectedGroupId();
    if (!mounted) return;
    setState(() {
      _savedGroups = groups;
      if (lastSelectedId != null && groups.any((g) => g.id == lastSelectedId)) {
        _selectedGroupId = lastSelectedId;
        final selectedGroup = groups.firstWhere((g) => g.id == lastSelectedId);
        _players = List.from(selectedGroup.players);
        _playerKeys.clear();
        for (var i = 0; i < _players.length; i++) {
          _playerKeys.add('p_${_nextPlayerKeyId++}');
        }
        final maxImposters = _players.length ~/ 2;
        if (_numImposters > maxImposters) {
          _numImposters = maxImposters.clamp(1, 9999);
        }
      }
    });
  }

  void _handleSelectGroup(PlayerGroup group) {
    setState(() {
      _selectedGroupId = group.id;
      _players = List.from(group.players);
      _playerKeys.clear();
      for (var i = 0; i < _players.length; i++) {
        _playerKeys.add('p_${_nextPlayerKeyId++}');
      }
      final maxImposters = _players.length ~/ 2;
      if (_numImposters > maxImposters) {
        _numImposters = maxImposters.clamp(1, 9999);
      }
    });
    GroupService.saveLastSelectedGroupId(group.id);
  }

  Future<void> _handleCreateGroup(String name) async {
    final validPlayers = resolvePlayerNames(_players);
    final newGroup = await GroupService.createGroup(name: name, players: validPlayers);
    final groups = await GroupService.loadGroups();
    if (!mounted) return;
    setState(() {
      _savedGroups = groups;
      _selectedGroupId = newGroup.id;
    });
  }

  Future<void> _handleRenameGroup(String groupId, String newName) async {
    await GroupService.renameGroup(groupId: groupId, newName: newName);
    final groups = await GroupService.loadGroups();
    if (!mounted) return;
    setState(() {
      _savedGroups = groups;
    });
  }

  Future<void> _handleUpdateGroup(PlayerGroup updated) async {
    final validPlayers = resolvePlayerNames(_players);
    await GroupService.updateGroup(updated.copyWith(players: validPlayers));
    final groups = await GroupService.loadGroups();
    if (!mounted) return;
    setState(() {
      _savedGroups = groups;
    });
  }

  Future<void> _handleDeleteGroup(String groupId) async {
    await GroupService.deleteGroup(groupId);
    final groups = await GroupService.loadGroups();
    if (!mounted) return;
    setState(() {
      _savedGroups = groups;
      if (_selectedGroupId == groupId) {
        _selectedGroupId = null;
      }
    });
  }

  void _handleClearGroup() {
    setState(() {
      _selectedGroupId = null;
    });
    GroupService.saveLastSelectedGroupId(null);
  }

  // Start game handler
  void _handleStartGame() {
    try {
      final round = createRound(
        CreateRoundParams(
          players: _players,
          selectedIndustries: _selectedIndustries,
          moviePool: kAllMovies,
          numImposters: _numImposters,
          imposterClueEnabled: _imposterClueEnabled,
          revealNameToImposter: _revealNameToImposter,
          discussionTimerMinutes: _discussionTimerMinutes,
          previousMovieId: _roundState?.movieId,
          previousClueKey: _previousClueKey,
          usedMovieIds: _usedMovieIds,
        ),
      );

      _usedMovieIds.add(round.movieId);
      _previousClueKey = round.imposterClueKey;

      setState(() {
        _roundState = round;
        _currentScreen = ScreenState.dealing;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '').replaceAll('ArgumentError: ', '')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  // Card dealing handlers
  void _handleNextPlayerCard() {
    if (_roundState != null) {
      setState(() {
        _roundState!.currentCardIndex++;
      });
    }
  }

  void _handleFinishDealing() {
    if (_roundState != null) {
      // Pick a random starting player, and maintain the circular seating order around the room
      final players = _roundState!.players;
      final startIdx = Random().nextInt(players.length);
      final circularOrder = List<String>.generate(
        players.length,
        (i) => players[(startIdx + i) % players.length],
      );
      setState(() {
        _roundState = _roundState!.copyWith(
          startingPlayer: circularOrder.first,
          discussionOrder: circularOrder,
          phase: RoundPhase.discussion,
        );
        _currentScreen = ScreenState.discussion;
      });
    }
  }

  void _handleNextRound() {
    if (_roundState != null) {
      try {
        final nextRound = createNextRound(
          _roundState!,
          moviePool: kAllMovies,
          usedMovieIds: _usedMovieIds,
        );
        _usedMovieIds.add(nextRound.movieId);
        _previousClueKey = nextRound.imposterClueKey;
        setState(() {
          _roundState = nextRound;
          _currentScreen = ScreenState.dealing;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start next round: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _handleReturnToSetup() {
    setState(() {
      _roundState = null;
      _currentScreen = ScreenState.setup;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService.checkAndShowUpdateDialog(context);
    });
  }

  Future<bool> _onWillPop() async {
    if (_currentScreen == ScreenState.setup) {
      return true; // Exit app
    }

    if (_currentScreen == ScreenState.dealing) {
      final shouldExit = await showDialog<bool>(
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
                child: const Icon(Icons.exit_to_app_rounded, color: AppColors.danger, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Exit Current Round?',
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
            'Going back will cancel the round in progress.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx, false),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.surfaceBorderDark),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text('Continue Playing', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text('Exit Round', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );

      if (shouldExit == true) {
        setState(() {
          _roundState = null;
          _currentScreen = ScreenState.setup;
        });
      }
      return false;
    }

    if (_currentScreen == ScreenState.discussion) {
      setState(() {
        _roundState = null;
        _currentScreen = ScreenState.setup;
      });
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentScreen == ScreenState.setup,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _onWillPop();
        }
      },
      child: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case ScreenState.setup:
        return SetupScreen(
          selectedIndustries: _selectedIndustries,
          onToggleIndustry: _handleToggleIndustry,
          onSelectAllIndustries: _handleSelectAllIndustries,
          players: _players,
          playerKeys: _playerKeys,
          savedGroups: _savedGroups,
          selectedGroupId: _selectedGroupId,
          onSelectGroup: _handleSelectGroup,
          onCreateGroup: _handleCreateGroup,
          onRenameGroup: _handleRenameGroup,
          onUpdateGroup: _handleUpdateGroup,
          onDeleteGroup: _handleDeleteGroup,
          onClearGroup: _handleClearGroup,
          onChangePlayer: _handleChangePlayer,
          onAddPlayer: _handleAddPlayer,
          onRemovePlayer: _handleRemovePlayer,
          onReorderPlayer: _handleReorderPlayer,
          numImposters: _numImposters,
          onChangeNumImposters: (count) {
            setState(() {
              _numImposters = count;
            });
          },
          imposterClueEnabled: _imposterClueEnabled,
          onToggleClueEnabled: (enabled) {
            setState(() {
              _imposterClueEnabled = enabled;
            });
          },
          revealNameToImposter: _revealNameToImposter,
          onToggleRevealNameToImposter: (enabled) {
            setState(() {
              _revealNameToImposter = enabled;
            });
          },
          discussionTimerMinutes: _discussionTimerMinutes,
          onChangeDiscussionTimer: (minutes) {
            setState(() {
              _discussionTimerMinutes = minutes;
            });
          },
          onStartGame: _handleStartGame,
        );

      case ScreenState.dealing:
        if (_roundState == null) return const SizedBox.shrink();
        return DealCardsScreen(
          assignments: _roundState!.assignments,
          currentCardIndex: _roundState!.currentCardIndex,
          onNextPlayer: _handleNextPlayerCard,
          onFinishDealing: _handleFinishDealing,
        );

      case ScreenState.discussion:
        if (_roundState == null) return const SizedBox.shrink();
        return DiscussionScreen(
          movieTitle: _roundState!.movieTitle,
          imposters: _roundState!.imposters,
          startingPlayer: _roundState!.startingPlayer,
          industry: _roundState!.industry,
          discussionTimerMinutes: _roundState!.discussionTimerMinutes,
          onReturnToSetup: _handleReturnToSetup,
          onNextRound: _handleNextRound,
        );
    }
  }
}
