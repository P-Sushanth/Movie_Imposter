import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_imposter/models/movie.dart';
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
          'Are you sure you want to start the next round? The phone will be passed around from the first player again with the same imposter and title.',
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
  });
}
