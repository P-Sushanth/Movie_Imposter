import 'package:flutter/material.dart';
import 'data/movies_data.dart';
import 'domain/game_setup.dart';
import 'models/movie.dart';
import 'models/round_state.dart';
import 'screens/deal_cards_screen.dart';
import 'screens/discussion_screen.dart';
import 'screens/setup_screen.dart';
import 'services/update_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

class _GameContainerState extends State<GameContainer> {
  ScreenState _currentScreen = ScreenState.setup;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService.checkAndShowUpdateDialog(context);
    });
  }

  // Setup state
  List<Industry> _selectedIndustries = [
    Industry.tollywood,
    Industry.bollywood,
    Industry.hollywood,
  ];
  List<String> _players = ['', '', ''];
  int _numImposters = 1;
  bool _imposterClueEnabled = true;

  // Active round state
  RoundState? _roundState;

  // Track movies played in this session only
  final Set<String> _usedMovieIds = <String>{};

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
    });
  }

  void _handleRemovePlayer(int index) {
    if (_players.length > 3) {
      setState(() {
        _players.removeAt(index);
        final maxImposters = _players.length ~/ 2;
        if (_numImposters > maxImposters) {
          _numImposters = maxImposters.clamp(1, 9999);
        }
      });
    }
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
          previousMovieId: _roundState?.movieId,
          usedMovieIds: _usedMovieIds,
        ),
      );

      _usedMovieIds.add(round.movieId);

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
      // When clicked on start discussion, choose a random person from the players to start the round,
      // and always randomize the speaking order.
      final shuffled = List<String>.from(_roundState!.players)..shuffle();
      setState(() {
        _roundState = _roundState!.copyWith(
          startingPlayer: shuffled.first,
          discussionOrder: shuffled,
          phase: RoundPhase.discussion,
        );
        _currentScreen = ScreenState.discussion;
      });
    }
  }

  void _handleReturnToSetup() {
    setState(() {
      _roundState = null;
      _currentScreen = ScreenState.setup;
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
          title: const Text('Exit Current Round?'),
          content: const Text('Going back will cancel the round in progress.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Continue Playing'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Exit Round'),
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
          onChangePlayer: _handleChangePlayer,
          onAddPlayer: _handleAddPlayer,
          onRemovePlayer: _handleRemovePlayer,
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
          onReturnToSetup: _handleReturnToSetup,
        );
    }
  }
}
