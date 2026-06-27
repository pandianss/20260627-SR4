import 'package:flutter/material.dart' hide Card;
import 'package:flutter_test/flutter_test.dart';
import 'package:app/screens/lesson_player_screen.dart';
import 'package:app/services/telemetry_service.dart';
import 'package:app/services/audio_narration_service.dart';
import 'package:app/theme/tokens.dart';
import 'package:store/store.dart';
import 'package:domain/domain.dart';

void main() {
  group('Accessibility Semantics (E10.1) Tests', () {
    testWidgets('LessonPlayerScreen renders semantics tree with action buttons', (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      final lesson = Lesson(
        id: 'les_ppb_crr',
        moduleId: 'm_ppb_a',
        title: const LocalizedString({'en': 'Cash Reserve Ratio'}),
        cards: [
          const Card(
            id: 'card_crr',
            kind: CardKind.concept,
            blocks: [
              TextBlock(LocalizedString({'en': 'Concept detailed description.'})),
            ],
            srsEligible: true,
          ),
        ],
        probeQuestionIds: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(AppTokens.dark),
          home: LessonPlayerScreen(
            lesson: lesson,
            questions: [],
            stimuli: [],
            userId: 'user_semantics_test',
            onComplete: (events) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify page is wrapped with correct card semantics (which merges child text)
      expect(
        find.bySemanticsLabel(RegExp(r'Concept card 1 of 1')),
        findsOneWidget,
      );

      // Verify speaker audio narration toggle button has semantics label
      expect(
        find.bySemanticsLabel(RegExp(r'Toggle Audio Narration')),
        findsOneWidget,
      );

      // Verify next card button has correct semantics
      expect(
        find.bySemanticsLabel(RegExp(r'Start Practice')),
        findsOneWidget,
      );

      handle.dispose();
    });
  });

  group('Offline Feedback Sync (E10.2 & E10.4) Tests', () {
    test('Logs FeedbackSubmittedEvent offline and serializes correctly', () async {
      final baseDate = DateTime(2026, 6, 23);
      final eventStore = MemoryEventLogStore();

      final feedbackEvent = FeedbackSubmittedEvent(
        clientUlid: 'ulid_fb_123',
        userId: 'user_sync_test',
        timestamp: baseDate,
        examContext: 'JAIIB',
        rating: 5,
        comments: 'Excellent bite-sized learning app.',
      );

      // Save offline
      await eventStore.appendEvent(feedbackEvent);

      final logged = await eventStore.getAllEvents('user_sync_test');
      expect(logged.length, equals(1));
      expect(logged.first, isA<FeedbackSubmittedEvent>());

      final fbEvent = logged.first as FeedbackSubmittedEvent;
      expect(fbEvent.rating, equals(5));
      expect(fbEvent.comments, equals('Excellent bite-sized learning app.'));

      // Test JSON round-trip
      final json = fbEvent.toJson();
      expect(json['type'], equals('feedback_submitted'));
      expect(json['rating'], equals(5));
      expect(json['comments'], equals('Excellent bite-sized learning app.'));

      final parsed = SrsEvent.fromJson(json) as FeedbackSubmittedEvent;
      expect(parsed.rating, equals(5));
      expect(parsed.comments, equals('Excellent bite-sized learning app.'));
    });

    test('ContentFlaggedEvent serialization and deserialization', () async {
      final eventStore = MemoryEventLogStore();
      final flagEvent = ContentFlaggedEvent(
        clientUlid: 'ulid_flag_test',
        userId: 'user_flag_test',
        timestamp: DateTime.parse('2026-06-27T08:32:00.000Z'),
        examContext: 'CAIIB',
        contentId: 'card-123',
        contentType: 'card',
        reason: 'Incorrect information: formula value is wrong',
      );

      await eventStore.appendEvent(flagEvent);
      final logged = await eventStore.getAllEvents('user_flag_test');
      expect(logged.length, equals(1));
      expect(logged.first, isA<ContentFlaggedEvent>());

      final parsedEvent = logged.first as ContentFlaggedEvent;
      expect(parsedEvent.contentId, equals('card-123'));
      expect(parsedEvent.contentType, equals('card'));
      expect(parsedEvent.reason, equals('Incorrect information: formula value is wrong'));

      final json = parsedEvent.toJson();
      expect(json['type'], equals('content_flagged'));
      expect(json['contentId'], equals('card-123'));
      expect(json['contentType'], equals('card'));
      expect(json['reason'], equals('Incorrect information: formula value is wrong'));

      final fromJsonEvent = SrsEvent.fromJson(json) as ContentFlaggedEvent;
      expect(fromJsonEvent.contentId, equals('card-123'));
      expect(fromJsonEvent.contentType, equals('card'));
      expect(fromJsonEvent.reason, equals('Incorrect information: formula value is wrong'));
    });
  });

  group('Telemetry & Diagnostics (E10.3) Tests', () {
    test('Logs error dumps and latency in TelemetryService', () {
      final telemetry = TelemetryService();
      expect(telemetry.bootLatency, isNull);
      expect(telemetry.getLogs(), isEmpty);

      // Set boot latency
      telemetry.setBootLatency(const Duration(milliseconds: 120));
      expect(telemetry.bootLatency?.inMilliseconds, equals(120));
      expect(telemetry.getLogs().length, equals(1));
      expect(telemetry.getLogs().first.message, contains('120ms'));

      // Log info and errors
      telemetry.logInfo('Sync trigger successful');
      telemetry.logError(FormatException('Parsing error'), StackTrace.current);

      final logs = telemetry.getLogs();
      expect(logs.length, equals(3));
      expect(logs[1].level, equals('INFO'));
      expect(logs[2].level, equals('ERROR'));
      expect(logs[2].message, contains('FormatException: Parsing error'));
      expect(logs[2].stackTrace, isNotNull);

      // Clear logs
      telemetry.clearLogs();
      expect(telemetry.getLogs(), isEmpty);
    });
  });

  group('Audio Narration Engine (E10.1) Tests', () {
    test('Simulates audio playback lifecycle and progresses indexes', () async {
      final narrator = AudioNarrationService();
      expect(narrator.isPlaying, isFalse);
      expect(narrator.isPaused, isFalse);
      expect(narrator.currentIndex, equals(-1));

      int progressIndex = -1;
      bool doneCalled = false;

      narrator.play(
        ['First sentence description.', 'Second card detail text.'],
        onProgress: (idx) => progressIndex = idx,
        onDone: () => doneCalled = true,
      );

      expect(narrator.isPlaying, isTrue);
      expect(narrator.isPaused, isFalse);
      expect(narrator.currentIndex, equals(0));
      expect(narrator.currentText, equals('First sentence description.'));

      // Pause playback
      narrator.pause();
      expect(narrator.isPaused, isTrue);

      // Resume playback
      narrator.resume();
      expect(narrator.isPaused, isFalse);

      // Stop playback
      narrator.stop();
      expect(narrator.isPlaying, isFalse);
      expect(narrator.currentIndex, equals(-1));
    });
  });
}
