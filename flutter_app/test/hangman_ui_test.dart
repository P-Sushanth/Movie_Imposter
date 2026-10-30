import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_imposter/domain/hangman.dart';
import 'package:movie_imposter/main.dart';
import 'package:movie_imposter/screens/game_hub_screen.dart';
import 'package:movie_imposter/screens/hangman_arena_screen.dart';
import 'package:movie_imposter/screens/hangman_team_setup_screen.dart';
import 'package:movie_imposter/screens/hangman_word_entry_screen.dart';

void main() {
  group('Hangman UI Tests', () {
    testWidgets('GameHubScreen renders titles, cards, and triggers callbacks', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool imposterClicked = false;
      bool hangmanClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: GameHubScreen(
            onPlayImposter: () => imposterClicked = true,
            onPlayHangman: () => hangmanClicked = true,
          ),
        ),
      );

      expect(find.text('Party Arcade'), findsOneWidget);
      expect(
        find.text('Choose an offline party game to play with friends.'),
        findsOneWidget,
      );
      expect(find.text('Movie Imposter'), findsOneWidget);
      expect(find.text('Hangman Battle'), findsOneWidget);
      expect(find.text('2 Teams • New'), findsOneWidget);

      await tester.tap(find.text('Play Imposter'));
      expect(imposterClicked, isTrue);

      await tester.tap(find.text('Start Hangman'));
      expect(hangmanClicked, isTrue);
    });

    testWidgets('HangmanTeamSetupScreen renders team inputs, rules, and proceeds to word entry', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool proceeded = false;
      String submittedTeamA = '';
      String submittedTeamB = '';

      const state = HangmanState(
        teamAName: 'Team Popcorn',
        teamBName: 'Team Cinema',
        settingTeam: HangmanTeamRole.teamA,
        secretWord: '',
        clues: [],
        guessedLetters: {},
        cluesViewed: false,
        scoreTeamA: 2,
        scoreTeamB: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HangmanTeamSetupScreen(
            state: state,
            onBackToHub: () {},
            onProceedToWordEntry: ({
              required teamAName,
              required teamBName,
            }) {
              proceeded = true;
              submittedTeamA = teamAName;
              submittedTeamB = teamBName;
            },
          ),
        ),
      );

      // Verify Scoreboard and Header
      expect(find.text('Team Setup'), findsOneWidget);
      expect(find.text('SESSION SCOREBOARD'), findsOneWidget);
      expect(find.text('Team Popcorn'), findsWidgets);
      expect(find.text('Team Cinema'), findsWidgets);

      // Verify Scoring Rules 1-line text
      expect(find.text('• Guess without clues: +2 Points'), findsOneWidget);
      expect(find.text('• Guess with clues opened: +1 Point'), findsOneWidget);
      expect(find.text('• 7 strikes hit: Setting team +1 Pt'), findsOneWidget);

      // Change team name and proceed
      await tester.enterText(find.byType(TextField).first, 'Superstars');
      await tester.tap(find.text('Enter Secret Word →'));
      await tester.pump();

      expect(proceeded, isTrue);
      expect(submittedTeamA, equals('Superstars'));
      expect(submittedTeamB, equals('Team Cinema'));
    });

    testWidgets('HangmanWordEntryScreen renders spotlight, secret word, clues, and locks word', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool locked = false;
      String submittedWord = '';
      List<String> submittedClues = [];

      const state = HangmanState(
        teamAName: 'Team Popcorn',
        teamBName: 'Team Cinema',
        settingTeam: HangmanTeamRole.teamA,
        secretWord: '',
        clues: [],
        guessedLetters: {},
        cluesViewed: false,
        scoreTeamA: 0,
        scoreTeamB: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HangmanWordEntryScreen(
            state: state,
            onBackToTeamSetup: () {},
            onLockWordAndPass: ({
              required secretWord,
              required clues,
            }) {
              locked = true;
              submittedWord = secretWord;
              submittedClues = clues;
            },
          ),
        ),
      );

      // Verify Word Creator Spotlight
      expect(find.text('WORD CREATOR'), findsOneWidget);
      expect(find.text('Team Popcorn'), findsWidgets);
      expect(find.text('Target for: Team Cinema'), findsOneWidget);
      expect(find.text('SECRET WORD *'), findsOneWidget);

      // Tap lock button without entering word -> validation error
      await tester.ensureVisible(find.text('Lock Word & Pass Phone →'));
      await tester.ensureVisible(find.text('Lock Word & Pass Phone →'));
      await tester.tap(find.text('Lock Word & Pass Phone →'));
      await tester.pump();
      expect(locked, isFalse);
      expect(find.text('Please enter a secret word, movie, or phrase.'), findsOneWidget);

      // Enter secret word & a clue
      await tester.enterText(find.byType(TextField).at(0), 'RRR');
      await tester.enterText(find.byType(TextField).at(1), 'Rajamouli epic');
      await tester.pump();

      await tester.ensureVisible(find.text('Lock Word & Pass Phone →'));
      await tester.tap(find.text('Lock Word & Pass Phone →'));
      await tester.pump();

      expect(locked, isTrue);
      expect(submittedWord, equals('RRR'));
      expect(submittedClues, equals(['Rajamouli epic']));
    });

    testWidgets('HangmanArenaScreen renders single-line header, strikes, keypad, and outcome', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      String lastGuessed = '';
      bool nextRoundCalled = false;

      var state = const HangmanState(
        teamAName: 'Popcorn',
        teamBName: 'Cinema',
        settingTeam: HangmanTeamRole.teamA,
        secretWord: 'DHOOM',
        clues: ['Bike heist', 'John Abraham'],
        guessedLetters: {'D', 'H'},
        cluesViewed: false,
        scoreTeamA: 1,
        scoreTeamB: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HangmanArenaScreen(
            state: state,
            onGuessLetter: (letter) => lastGuessed = letter,
            onOpenClues: () {},
            onNextRound: () => nextRoundCalled = true,
            onBackToHub: () {},
          ),
        ),
      );

      // Verify single-line header
      expect(find.text('Popcorn: 1  |  Cinema: 0'), findsOneWidget);
      expect(find.text('[CLUES 2]'), findsOneWidget);
      expect(find.text('• +2 PTS'), findsOneWidget);

      // Guess a letter via Keypad (tap InkWell containing 'M')
      final mKey = find.widgetWithText(InkWell, 'M');
      await tester.tap(mKey);
      await tester.pump();
      expect(lastGuessed, equals('M'));

      // Test with all letters guessed to verify outcome modal
      final solvedState = state.copyWith(
        guessedLetters: {'D', 'H', 'O', 'M'},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HangmanArenaScreen(
            state: solvedState,
            onGuessLetter: (_) {},
            onOpenClues: () {},
            onNextRound: () => nextRoundCalled = true,
            onBackToHub: () {},
          ),
        ),
      );

      // Stamp must be strictly retro rubber stamp with NO emojis
      expect(find.text('[ WORD GUESSED ]'), findsOneWidget);
      expect(find.text('DHOOM'), findsOneWidget);
      expect(find.text('+2 PTS'), findsOneWidget);
      expect(find.text('Bonus: Solved without viewing clues (+2 Pts)!'), findsOneWidget);

      await tester.tap(find.text('Swap Roles & Next Round →'));
      expect(nextRoundCalled, isTrue);
    });

    testWidgets('prompts to reset or continue previous hangman session when re-selected from Hub', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MovieImposterApp());
      await tester.pumpAndSettle();

      // 1. Initial Launch: on Game Hub
      expect(find.text('Party Arcade'), findsOneWidget);
      await tester.tap(find.text('Start Hangman'));
      await tester.pumpAndSettle();

      // 2. Fresh setup: Step 1 is Team Setup screen
      expect(find.text('Team Setup'), findsOneWidget);
      await tester.tap(find.text('Enter Secret Word →'));
      await tester.pumpAndSettle();

      // Step 2 is Word Entry screen
      expect(find.text('Word Entry'), findsOneWidget);

      // Enter secret word and lock it
      await tester.enterText(find.byType(TextField).at(0), 'KANTARA');
      await tester.ensureVisible(find.text('Lock Word & Pass Phone →'));
      await tester.tap(find.text('Lock Word & Pass Phone →'));
      await tester.pumpAndSettle();

      // 3. Now in Arena, simulate exiting back to Game Hub via Hardware Back
      expect(find.text('TEAM CINEMA\'S TURN TO GUESS'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      // Exit confirmation dialog in Arena
      expect(find.text('Exit Hangman Round?'), findsOneWidget);
      await tester.tap(find.text('Exit Round'));
      await tester.pumpAndSettle();

      // Now back in Word Entry, tap Back arrow to return to Team Setup
      expect(find.text('Word Entry'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Now on Team Setup, tap Back arrow to return to Game Hub
      expect(find.text('Team Setup'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // 4. Back on Game Hub: Select Hangman again!
      expect(find.text('Party Arcade'), findsOneWidget);
      await tester.tap(find.text('Start Hangman'));
      await tester.pumpAndSettle();

      // 5. Prompt appears: Continue Hangman Session?
      expect(find.text('Continue Hangman Session?'), findsOneWidget);
      expect(find.text('Reset & Start Fresh'), findsOneWidget);
      expect(find.text('Continue Session'), findsOneWidget);

      // Choose "Continue Session" -> resumes round in Arena
      await tester.tap(find.text('Continue Session'));
      await tester.pumpAndSettle();
      expect(find.text('TEAM CINEMA\'S TURN TO GUESS'), findsOneWidget);

      // Return to Hub again
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Exit Round'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Re-select Hangman and choose "Reset & Start Fresh"
      await tester.tap(find.text('Start Hangman'));
      await tester.pumpAndSettle();
      expect(find.text('Continue Hangman Session?'), findsOneWidget);

      await tester.tap(find.text('Reset & Start Fresh'));
      await tester.pumpAndSettle();

      // Now back at fresh Team Setup
      expect(find.text('Team Setup'), findsOneWidget);
    });
  });
}
