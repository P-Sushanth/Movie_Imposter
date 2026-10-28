import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_imposter/domain/game_setup.dart';
import 'package:movie_imposter/models/movie.dart';
import 'package:movie_imposter/models/role.dart';
import 'package:movie_imposter/screens/discussion_screen.dart';

void main() {
  group('DiscussionScreen - Next Round & Reveal', () {
    testWidgets('renders Discussion Time, Next Round, and Reveal Imposter buttons', (tester) async {
      bool nextRoundCalled = false;
      bool returnToSetupCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: DiscussionScreen(
            movieTitle: 'Inception',
            imposters: const ['Alice'],
            startingPlayer: 'Bob',
            industry: Industry.hollywood,
            onReturnToSetup: () {
              returnToSetupCalled = true;
            },
            onNextRound: () {
              nextRoundCalled = true;
            },
          ),
        ),
      );

      expect(find.text('Discussion Time'), findsOneWidget);
      expect(find.text('STARTS THE ROUND'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Next Round'), findsOneWidget);
      expect(find.text('Reveal Imposter'), findsOneWidget);
      expect(find.text('Back to Setup'), findsNothing);

      expect(nextRoundCalled, isFalse);
      expect(returnToSetupCalled, isFalse);
    });

    testWidgets('Next Round button shows confirmation dialog and triggers onNextRound on confirmation', (tester) async {
      bool nextRoundCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: DiscussionScreen(
            movieTitle: 'Inception',
            imposters: const ['Alice'],
            startingPlayer: 'Bob',
            industry: Industry.hollywood,
            onReturnToSetup: () {},
            onNextRound: () {
              nextRoundCalled = true;
            },
          ),
        ),
      );

      // Tap Next Round
      await tester.tap(find.text('Next Round'));
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.text('Start Next Round?'), findsOneWidget);
      expect(
        find.text(
          'Are you sure you want to start the next round? The phone will be passed around from the first player again with a new name and the same imposter.',
        ),
        findsOneWidget,
      );

      // Tap Cancel first
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(nextRoundCalled, isFalse);
      expect(find.text('Start Next Round?'), findsNothing);

      // Tap Next Round again
      await tester.tap(find.text('Next Round'));
      await tester.pumpAndSettle();

      // Tap the confirm button in dialog (the one inside AlertDialog)
      final dialogNextRoundButton = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Next Round'),
      );
      await tester.tap(dialogNextRoundButton);
      await tester.pumpAndSettle();

      expect(nextRoundCalled, isTrue);
    });

    testWidgets('Reveal Imposter shows confirmation and switches to revealed view with Back to Setup', (tester) async {
      bool returnToSetupCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: DiscussionScreen(
            movieTitle: 'Inception',
            imposters: const ['Alice'],
            startingPlayer: 'Bob',
            industry: Industry.hollywood,
            onReturnToSetup: () {
              returnToSetupCalled = true;
            },
            onNextRound: () {},
          ),
        ),
      );

      // Tap Reveal Imposter
      await tester.tap(find.text('Reveal Imposter'));
      await tester.pumpAndSettle();

      expect(find.text('Reveal Imposter?'), findsOneWidget);

      // Confirm Reveal
      await tester.tap(find.text('Yes, Reveal'));
      await tester.pumpAndSettle();

      // Revealed state checks
      expect(find.text('THE IMPOSTER WAS'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('THE MOVIE'), findsOneWidget);
      expect(find.text('Inception'), findsOneWidget);

      // Next Round should no longer be visible after reveal
      expect(find.text('Next Round'), findsNothing);
      expect(find.text('Back to Setup'), findsOneWidget);

      // Tap Back to Setup
      await tester.tap(find.text('Back to Setup'));
      expect(returnToSetupCalled, isTrue);
    });

    testWidgets('discussion timer is hidden when discussionTimerMinutes is 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DiscussionScreen(
            movieTitle: 'Inception',
            imposters: const ['Alice'],
            startingPlayer: 'Bob',
            industry: Industry.hollywood,
            discussionTimerMinutes: 0,
            onReturnToSetup: () {},
            onNextRound: () {},
          ),
        ),
      );

      expect(find.text('DISCUSSION TIME REMAINING'), findsNothing);
    });

    testWidgets('discussion timer counts down and displays times up message when expired', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DiscussionScreen(
            movieTitle: 'Inception',
            imposters: const ['Alice'],
            startingPlayer: 'Bob',
            industry: Industry.hollywood,
            discussionTimerMinutes: 1,
            onReturnToSetup: () {},
            onNextRound: () {},
          ),
        ),
      );

      expect(find.text('DISCUSSION TIME REMAINING'), findsOneWidget);
      expect(find.text('01:00'), findsOneWidget);

      // Advance 1 second
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('00:59'), findsOneWidget);

      // Advance 59 more seconds to hit 0
      await tester.pump(const Duration(seconds: 59));
      expect(find.text('00:00'), findsOneWidget);
      expect(find.text("TIME'S UP! VOTE NOW"), findsOneWidget);
    });

    test('createNextRound selects a new movie from selected categories and preserves the imposter', () {
      const pool = [
        Movie(
          id: 'm1',
          title: 'Movie One',
          industry: Industry.tollywood,
          genre: 'Action',
        ),
        Movie(
          id: 'm2',
          title: 'Movie Two',
          industry: Industry.tollywood,
          genre: 'Comedy',
        ),
      ];

      final round1 = createRound(
        CreateRoundParams(
          players: ['Alice', 'Bob', 'Charlie'],
          selectedIndustries: [Industry.tollywood],
          moviePool: pool,
          numImposters: 1,
          imposterClueEnabled: false,
        ),
      );

      final nextRound = createNextRound(
        round1,
        moviePool: pool,
        usedMovieIds: {round1.movieId},
      );

      expect(nextRound.imposters, equals(round1.imposters));
      expect(nextRound.movieId, isNot(equals(round1.movieId)));
      expect(nextRound.currentCardIndex, equals(0));

      final normalAssignment = nextRound.assignments.firstWhere(
        (a) => a.role is NormalPlayerRole,
      );
      expect((normalAssignment.role as NormalPlayerRole).movieTitle, equals(nextRound.movieTitle));
    });

    test('createRound applies weighted soft bias against previous imposters', () {
      const pool = [
        Movie(
          id: 'm1',
          title: 'Movie One',
          industry: Industry.tollywood,
          genre: 'Action',
        ),
      ];

      final players = ['Alice', 'Bob', 'Charlie', 'David'];
      int aliceCount = 0;
      const trials = 1000;

      for (int i = 0; i < trials; i++) {
        final round = createRound(
          CreateRoundParams(
            players: players,
            selectedIndustries: [Industry.tollywood],
            moviePool: pool,
            numImposters: 1,
            imposterClueEnabled: false,
            previousImposters: ['Alice'],
          ),
        );
        if (round.imposters.contains('Alice')) {
          aliceCount++;
        }
      }

      // Theoretical probability: 0.5 / 3.5 ≈ 14.3% (~143 out of 1000).
      // Much lower than uniform 25% (250), but strictly > 0 (not 100% excluded).
      expect(aliceCount, greaterThan(60));
      expect(aliceCount, lessThan(220));
    });
  });
}
