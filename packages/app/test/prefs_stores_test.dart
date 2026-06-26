import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srs/srs.dart';
import 'package:store/store.dart';
import 'package:app/data/prefs_stores.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  CardReviewedEvent review(String ulid, {String user = 'alice'}) =>
      CardReviewedEvent(
        clientUlid: ulid,
        userId: user,
        timestamp: DateTime.utc(2026, 6, 1),
        examContext: 'CAIIB',
        itemId: 'card_1',
        rating: Rating.good,
      );

  test('events survive a simulated relaunch', () async {
    final prefs = await SharedPreferences.getInstance();
    final store1 = await PrefsEventLogStore.create(prefs);
    await store1.appendEvent(review('u1'));

    // Re-create from the same prefs to simulate a fresh app launch.
    final store2 = await PrefsEventLogStore.create(prefs);
    final events = await store2.getAllEvents('alice');
    expect(events, hasLength(1));
    expect(events.first, isA<CardReviewedEvent>());
  });

  test('appendEvent dedups by clientUlid', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = await PrefsEventLogStore.create(prefs);
    await store.appendEvent(review('dup'));
    await store.appendEvent(review('dup'));
    expect(await store.getAllEvents('alice'), hasLength(1));
  });

  test('unsynced tracking persists across relaunch', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = await PrefsEventLogStore.create(prefs);
    await store.appendEvent(review('x'));
    expect(await store.getUnsyncedEvents('alice'), hasLength(1));

    await store.markEventsAsSynced(['x'], DateTime.utc(2026, 6, 2));
    final reopened = await PrefsEventLogStore.create(prefs);
    expect(await reopened.getUnsyncedEvents('alice'), isEmpty);
  });

  test('SRS state survives relaunch and filters by exam', () async {
    final prefs = await SharedPreferences.getInstance();
    final store1 = await PrefsSrsStateStore.create(prefs);
    await store1.saveState(SrsState(
      stability: 3,
      difficulty: 5,
      due: DateTime.utc(2026, 6, 10),
      lastReview: DateTime.utc(2026, 6, 1),
      userId: 'alice',
      itemId: 'card_1',
      examContext: 'CAIIB',
    ));

    final store2 = await PrefsSrsStateStore.create(prefs);
    expect(await store2.getState('alice', 'card_1'), isNotNull);
    expect(await store2.getStatesForExam('alice', 'CAIIB'), hasLength(1));
    expect(await store2.getStatesForExam('alice', 'JAIIB'), isEmpty);
  });
}
