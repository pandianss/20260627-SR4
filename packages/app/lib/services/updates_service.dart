import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/regulatory_update.dart';

/// Where the feed shown to the user actually came from.
enum UpdatesSource { network, cache, bundled }

class UpdatesResult {
  final UpdatesFeed feed;
  final UpdatesSource source;
  final DateTime? fetchedAt;
  const UpdatesResult({
    required this.feed,
    required this.source,
    required this.fetchedAt,
  });
}

/// Loads the regulatory-updates feed with a network → cache → bundled-seed
/// fallback chain, so the Updates tab always has something to show and works
/// offline. The curated feed itself is produced by the ingestion pipeline and
/// hosted as a static JSON (CDN / object storage).
class UpdatesService {
  UpdatesService({String? feedUrl, http.Client? client})
      : feedUrl = feedUrl ?? _defaultFeedUrl,
        _client = client ?? http.Client();

  /// Override at build time with
  /// `--dart-define=UPDATES_FEED_URL=https://…/content_pack_updates.json`.
  /// Empty by default so dev builds fall straight through to the bundled seed.
  static const _defaultFeedUrl =
      String.fromEnvironment('UPDATES_FEED_URL', defaultValue: '');

  static const _bundledAsset = 'assets/content_pack_updates.json';
  static const _cacheKey = 'updates_feed_cache_v1';
  static const _cacheAtKey = 'updates_feed_cached_at_v1';
  static const _lastSeenKey = 'updates_last_seen_v1';

  final String feedUrl;
  final http.Client _client;

  /// Resolve the feed. Tries the network first (when a URL is configured),
  /// falling back to the last cached copy and finally the bundled seed.
  Future<UpdatesResult> load({bool forceRefresh = false}) async {
    if (feedUrl.isNotEmpty) {
      try {
        final resp = await _client
            .get(Uri.parse(feedUrl))
            .timeout(const Duration(seconds: 8));
        if (resp.statusCode == 200) {
          await _writeCache(resp.body);
          return UpdatesResult(
            feed: _parse(resp.body),
            source: UpdatesSource.network,
            fetchedAt: DateTime.now(),
          );
        }
        debugPrint('UpdatesService: feed returned ${resp.statusCode}');
      } catch (e) {
        debugPrint('UpdatesService: network fetch failed ($e)');
      }
    }

    final cached = await _readCache();
    if (cached != null) {
      return UpdatesResult(
        feed: _parse(cached.body),
        source: UpdatesSource.cache,
        fetchedAt: cached.at,
      );
    }

    final seed = await rootBundle.loadString(_bundledAsset);
    return UpdatesResult(
      feed: _parse(seed),
      source: UpdatesSource.bundled,
      fetchedAt: null,
    );
  }

  UpdatesFeed _parse(String body) {
    try {
      return UpdatesFeed.fromJson(jsonDecode(body) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('UpdatesService: failed to parse feed ($e)');
      return UpdatesFeed.empty;
    }
  }

  Future<void> _writeCache(String body) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, body);
    await prefs.setString(_cacheAtKey, DateTime.now().toIso8601String());
  }

  Future<({String body, DateTime? at})?> _readCache() async {
    final prefs = await SharedPreferences.getInstance();
    final body = prefs.getString(_cacheKey);
    if (body == null) return null;
    final at = DateTime.tryParse(prefs.getString(_cacheAtKey) ?? '');
    return (body: body, at: at);
  }

  // ── Unread tracking ────────────────────────────────────────────────────────

  /// When the user last opened the Updates tab. Null means never.
  Future<DateTime?> lastSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return DateTime.tryParse(prefs.getString(_lastSeenKey) ?? '');
  }

  /// Mark everything up to [when] (default now) as seen.
  Future<void> markSeen([DateTime? when]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _lastSeenKey, (when ?? DateTime.now()).toIso8601String());
  }
}
