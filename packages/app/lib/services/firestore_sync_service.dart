import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:srs/srs.dart';
import 'package:store/store.dart';

/// Two-way sync of the local event log + SRS states to Firestore under
/// `users/{uid}`.
///
/// Events are append-only and conflict-free, so they sync cleanly in both
/// directions (deduped by `clientUlid`). SRS states are pushed as a backup and,
/// on pull, only applied where the device has no local state for that item — so
/// a fresh device is restored without ever clobbering newer local progress.
class FirestoreSyncService {
  FirestoreSyncService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _eventsCol(String uid) =>
      _db.collection('users').doc(uid).collection('events');

  CollectionReference<Map<String, dynamic>> _statesCol(String uid) =>
      _db.collection('users').doc(uid).collection('srsStates');

  /// Pull remote → local, then push local → remote. When [scheduler] +
  /// [examContext] are supplied, SRS states are re-projected from the merged
  /// event log after the pull (so a second device's progress is rebuilt
  /// correctly, not just gap-filled).
  Future<void> sync(
    String uid,
    EventLogStore events,
    SrsStateStore states, {
    Scheduler? scheduler,
    String? examContext,
  }) async {
    await pull(uid, events, states,
        scheduler: scheduler, examContext: examContext);
    await push(uid, events, states);
  }

  /// Push not-yet-synced events and a backup of all local states.
  Future<void> push(
      String uid, EventLogStore events, SrsStateStore states) async {
    final unsynced = await events.getUnsyncedEvents(uid);
    if (unsynced.isNotEmpty) {
      final batch = _db.batch();
      for (final e in unsynced) {
        batch.set(_eventsCol(uid).doc(e.clientUlid), e.toJson());
      }
      await batch.commit();
      await events.markEventsAsSynced(
          unsynced.map((e) => e.clientUlid).toList(), DateTime.now());
    }

    final localStates = await states.getAllStates(uid);
    if (localStates.isNotEmpty) {
      final batch = _db.batch();
      for (final s in localStates) {
        batch.set(_statesCol(uid).doc(s.itemId), s.toJson());
      }
      await batch.commit();
    }
  }

  /// Permanently delete all of a user's cloud data: every events/srsStates doc
  /// and the parent users/{uid} document. (Batches are capped at 500 ops, which
  /// comfortably covers a single learner's footprint.)
  Future<void> deleteUserData(String uid) async {
    for (final col in [_eventsCol(uid), _statesCol(uid)]) {
      final snap = await col.get();
      if (snap.docs.isEmpty) continue;
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
    await _db.collection('users').doc(uid).delete();
  }

  /// Pull remote events (append + mark synced so they aren't echoed back), then
  /// rebuild SRS states. With a [scheduler] + [examContext], states are
  /// re-projected from the full event log; otherwise remote state snapshots only
  /// fill local gaps.
  Future<void> pull(
    String uid,
    EventLogStore events,
    SrsStateStore states, {
    Scheduler? scheduler,
    String? examContext,
  }) async {
    final remoteEvents = await _eventsCol(uid).get();
    final pulled = <String>[];
    for (final doc in remoteEvents.docs) {
      try {
        final e = SrsEvent.fromJson(doc.data());
        await events.appendEvent(e); // store dedups by clientUlid
        pulled.add(e.clientUlid);
      } catch (_) {
        // Skip malformed remote records.
      }
    }
    if (pulled.isNotEmpty) {
      await events.markEventsAsSynced(pulled, DateTime.now());
    }

    if (scheduler != null && examContext != null) {
      await _reprojectStates(uid, events, states, scheduler, examContext);
      return;
    }

    // Fallback (no scheduler): fill local gaps from remote state snapshots.
    final remoteStates = await _statesCol(uid).get();
    for (final doc in remoteStates.docs) {
      try {
        final s = SrsState.fromJson(doc.data());
        if (await states.getState(uid, s.itemId) == null) {
          await states.saveState(s);
        }
      } catch (_) {
        // Skip malformed remote records.
      }
    }
  }

  /// Live multi-device sync: subscribe to remote event changes and merge any
  /// brand-new events into the local store (re-projecting SRS state), invoking
  /// [onChanged] only when local data actually changed (so a device's own
  /// writes, which are deduped, don't trigger a needless refresh). Returns the
  /// subscription for the caller to cancel.
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
      listenForRemoteChanges(
    String uid,
    EventLogStore events,
    SrsStateStore states, {
    required Scheduler scheduler,
    required String examContext,
    required void Function() onChanged,
  }) {
    return _eventsCol(uid).snapshots().listen((snap) async {
      final existing =
          (await events.getAllEvents(uid)).map((e) => e.clientUlid).toSet();
      final fresh = <SrsEvent>[];
      for (final change in snap.docChanges) {
        if (change.type != DocumentChangeType.added) continue;
        final data = change.doc.data();
        if (data == null) continue;
        try {
          final e = SrsEvent.fromJson(data);
          if (!existing.contains(e.clientUlid)) fresh.add(e);
        } catch (_) {}
      }
      if (fresh.isEmpty) return;
      for (final e in fresh) {
        await events.appendEvent(e);
      }
      await events.markEventsAsSynced(
          fresh.map((e) => e.clientUlid).toList(), DateTime.now());
      await _reprojectStates(uid, events, states, scheduler, examContext);
      onChanged();
    });
  }

  /// Rebuild every item's SRS state by replaying its events through the
  /// scheduler — keeps a second device's schedule consistent after a pull.
  Future<void> _reprojectStates(
    String uid,
    EventLogStore events,
    SrsStateStore states,
    Scheduler scheduler,
    String examContext,
  ) async {
    final all = await events.getAllEvents(uid);
    final itemIds = <String>{};
    for (final e in all) {
      if (e is CardReviewedEvent) {
        itemIds.add(e.itemId);
      } else if (e is QuestionAnsweredEvent) {
        itemIds.add(e.questionId);
      } else if (e is MockSubmittedEvent) {
        for (final a in e.answers) {
          itemIds.add(a.questionId);
        }
      }
    }
    for (final itemId in itemIds) {
      final itemEvents = await events.getEventsForItem(uid, itemId);
      final next = projectSrsState(
        userId: uid,
        itemId: itemId,
        events: itemEvents,
        scheduler: scheduler,
        examContext: examContext,
      );
      if (next != null) await states.saveState(next);
    }
  }
}
