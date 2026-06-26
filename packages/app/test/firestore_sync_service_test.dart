import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:srs/srs.dart';
import 'package:store/store.dart';
import 'package:app/services/firestore_sync_service.dart';

CardReviewedEvent _review(String ulid, {String uid = 'u1'}) => CardReviewedEvent(
      clientUlid: ulid,
      userId: uid,
      timestamp: DateTime.utc(2026, 6, 1),
      examContext: 'CAIIB',
      itemId: 'card_1',
      rating: Rating.good,
    );

void main() {
  test('push uploads unsynced events and marks them synced', () async {
    final db = FakeFirebaseFirestore();
    final sync = FirestoreSyncService(firestore: db);
    final events = MemoryEventLogStore();
    final states = MemorySrsStateStore();
    await events.appendEvent(_review('e1'));

    await sync.push('u1', events, states);

    final remote = await db.collection('users').doc('u1').collection('events').get();
    expect(remote.docs, hasLength(1));
    expect(await events.getUnsyncedEvents('u1'), isEmpty); // now marked synced
  });

  test('pull restores remote events into a fresh local store', () async {
    final db = FakeFirebaseFirestore();
    await db
        .collection('users').doc('u1').collection('events').doc('e1')
        .set(_review('e1').toJson());

    final sync = FirestoreSyncService(firestore: db);
    final events = MemoryEventLogStore();
    final states = MemorySrsStateStore();

    await sync.pull('u1', events, states);

    final local = await events.getAllEvents('u1');
    expect(local, hasLength(1));
    // Pulled events are marked synced so they aren't echoed back on push.
    expect(await events.getUnsyncedEvents('u1'), isEmpty);
  });

  test('round-trip sync between two devices via the same cloud', () async {
    final db = FakeFirebaseFirestore();

    // Device A logs a review and syncs up.
    final eventsA = MemoryEventLogStore();
    await eventsA.appendEvent(_review('e1'));
    await FirestoreSyncService(firestore: db)
        .sync('u1', eventsA, MemorySrsStateStore());

    // Device B (empty) syncs and receives it.
    final eventsB = MemoryEventLogStore();
    await FirestoreSyncService(firestore: db)
        .sync('u1', eventsB, MemorySrsStateStore());

    expect(await eventsB.getAllEvents('u1'), hasLength(1));
  });
}
