import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:srs/srs.dart';
import 'package:store/store.dart';

/// SharedPreferences-backed implementations of the event/SRS/sync stores, so a
/// learner's progress and spaced-repetition schedule survive app restarts
/// (previously the in-memory stores wiped everything on relaunch).
///
/// Each store loads its data once via [create], keeps it in memory for fast
/// reads, and write-throughs to prefs on every mutation. Reuses the existing
/// `toJson`/`fromJson` on [SrsEvent] and [SrsState] — no model changes.
///
/// These are the durable *local* layer; the unsynced-event bookkeeping and
/// [PrefsSyncCursorStore] are what a future Firestore sync pushes from.

class PrefsEventLogStore implements EventLogStore {
  static const _eventsKey = 'event_log_v1';
  static const _syncedKey = 'event_synced_v1';

  final SharedPreferences _prefs;
  final List<SrsEvent> _events;
  final Map<String, DateTime> _synced;

  PrefsEventLogStore._(this._prefs, this._events, this._synced);

  static Future<PrefsEventLogStore> create(SharedPreferences prefs) async {
    final events = <SrsEvent>[];
    final rawEvents = prefs.getString(_eventsKey);
    if (rawEvents != null) {
      for (final e in (jsonDecode(rawEvents) as List)) {
        try {
          events.add(SrsEvent.fromJson((e as Map).cast<String, dynamic>()));
        } catch (_) {
          // Skip corrupt / unknown-type records rather than losing the whole log.
        }
      }
    }

    final synced = <String, DateTime>{};
    final rawSynced = prefs.getString(_syncedKey);
    if (rawSynced != null) {
      (jsonDecode(rawSynced) as Map).forEach((k, v) {
        final at = DateTime.tryParse(v as String);
        if (at != null) synced[k as String] = at;
      });
    }

    return PrefsEventLogStore._(prefs, events, synced);
  }

  Future<void> _persistEvents() => _prefs.setString(
      _eventsKey, jsonEncode(_events.map((e) => e.toJson()).toList()));

  Future<void> _persistSynced() => _prefs.setString(_syncedKey,
      jsonEncode(_synced.map((k, v) => MapEntry(k, v.toIso8601String()))));

  @override
  Future<void> appendEvent(SrsEvent event) async {
    if (_events.any((e) => e.clientUlid == event.clientUlid)) return;
    _events.add(event);
    await _persistEvents();
  }

  @override
  Future<List<SrsEvent>> getUnsyncedEvents(String userId) async => _events
      .where((e) => e.userId == userId && !_synced.containsKey(e.clientUlid))
      .toList();

  @override
  Future<void> markEventsAsSynced(
      List<String> clientUlids, DateTime syncedAt) async {
    for (final ulid in clientUlids) {
      _synced[ulid] = syncedAt;
    }
    await _persistSynced();
  }

  @override
  Future<List<SrsEvent>> getEventsForItem(String userId, String itemId) async {
    final filtered = <SrsEvent>[];
    for (final event in _events) {
      if (event.userId != userId) continue;
      if (event is CardReviewedEvent && event.itemId == itemId) {
        filtered.add(event);
      } else if (event is QuestionAnsweredEvent && event.questionId == itemId) {
        filtered.add(event);
      } else if (event is MockSubmittedEvent &&
          event.answers.any((a) => a.questionId == itemId)) {
        filtered.add(event);
      }
    }
    filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return filtered;
  }

  @override
  Future<List<SrsEvent>> getAllEvents(String userId) async {
    final list = _events.where((e) => e.userId == userId).toList();
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return list;
  }
}

class PrefsSrsStateStore implements SrsStateStore {
  static const _statesKey = 'srs_states_v1';

  final SharedPreferences _prefs;
  final Map<String, SrsState> _states;

  PrefsSrsStateStore._(this._prefs, this._states);

  static Future<PrefsSrsStateStore> create(SharedPreferences prefs) async {
    final states = <String, SrsState>{};
    final raw = prefs.getString(_statesKey);
    if (raw != null) {
      (jsonDecode(raw) as Map).forEach((k, v) {
        try {
          states[k as String] =
              SrsState.fromJson((v as Map).cast<String, dynamic>());
        } catch (_) {
          // Skip corrupt records.
        }
      });
    }
    return PrefsSrsStateStore._(prefs, states);
  }

  String _key(String userId, String itemId) => '$userId::$itemId';

  Future<void> _persist() => _prefs.setString(
      _statesKey, jsonEncode(_states.map((k, v) => MapEntry(k, v.toJson()))));

  @override
  Future<void> saveState(SrsState state) async {
    _states[_key(state.userId, state.itemId)] = state;
    await _persist();
  }

  @override
  Future<SrsState?> getState(String userId, String itemId) async =>
      _states[_key(userId, itemId)];

  @override
  Future<List<SrsState>> getAllStates(String userId) async =>
      _states.values.where((s) => s.userId == userId).toList();

  @override
  Future<List<SrsState>> getStatesForExam(
          String userId, String examContext) async =>
      _states.values
          .where((s) => s.userId == userId && s.examContext == examContext)
          .toList();
}

class PrefsSyncCursorStore implements SyncCursorStore {
  static const _prefix = 'sync_cursor_v1';

  final SharedPreferences _prefs;
  PrefsSyncCursorStore(this._prefs);

  String _key(String userId) => '$_prefix::$userId';

  @override
  Future<DateTime?> getLastSyncTime(String userId) async =>
      DateTime.tryParse(_prefs.getString(_key(userId)) ?? '');

  @override
  Future<void> setLastSyncTime(String userId, DateTime time) async =>
      _prefs.setString(_key(userId), time.toIso8601String());
}
