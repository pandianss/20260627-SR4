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

  /// Pull remote → local, then push local → remote.
  Future<void> sync(
      String uid, EventLogStore events, SrsStateStore states) async {
    await pull(uid, events, states);
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

  /// Pull remote events (append + mark synced so they aren't echoed back) and
  /// remote states (only to fill local gaps).
  Future<void> pull(
      String uid, EventLogStore events, SrsStateStore states) async {
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
}
