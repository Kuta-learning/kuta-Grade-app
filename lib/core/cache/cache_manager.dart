import 'dart:async';
import 'package:flutter/foundation.dart';
import '../storage/local_storage.dart';
import '../storage/shared_prefs_storage.dart';
import '../storage/storage_keys.dart';
import 'cache_response.dart';

class _MemoryCacheEntry {
  final dynamic data;
  final DateTime timestamp;

  _MemoryCacheEntry({required this.data, required this.timestamp});
}

/// Centralized, type-safe multi-tier cache engine implementing the
/// Stale-While-Revalidate (SWR) caching pattern for Flutter apps.
///
/// Features:
/// - L1 In-Memory Cache (0ms instant retrieval).
/// - L2 Persistent Disk Storage via [LocalStorage] / [SharedPrefsStorage].
/// - Guard validation to reject mismatched / invalid cached items (e.g. cross-grade data).
/// - Background silent revalidation for stale data without UI spinners.
/// - Graceful offline error handling (keeps stale data visible on failure).
/// - Full debug logging to easily trace cache state transitions.
/// - Safe cache clearing: only purges cached payloads without erasing user flags (e.g. [hasSeenOnboarding]).
class CacheManager {
  static CacheManager? _instance;
  static const String _trackedKeysStorageKey = '__cache_manager_tracked_keys__';

  final LocalStorage? _customStorage;
  final Map<String, _MemoryCacheEntry> _memoryCache = {};
  final Set<String> _trackedKeys = {};

  CacheManager({LocalStorage? storage}) : _customStorage = storage;

  /// Global shared instance.
  static CacheManager get instance => _instance ??= CacheManager();

  /// Visible for testing to inject mock cache managers.
  static set instance(CacheManager value) => _instance = value;

  Future<LocalStorage> _getStorage() async {
    if (_customStorage != null) return _customStorage;
    final inst = SharedPrefsStorage.instanceOrNull;
    if (inst != null) return inst;
    return await SharedPrefsStorage.getInstance();
  }

  String _timeKey(String key) => '$key:timestamp';

  /// Watches a resource with Stale-While-Revalidate semantics.
  ///
  /// 1. Emits cached data immediately if available (L1 memory or L2 disk).
  /// 2. If [guard] is provided and returns false, the cached item is treated as invalid
  ///    and discarded, triggering an immediate network fetch.
  /// 3. If the cached data is fresh (age <= [ttl]), stops here.
  /// 4. If stale (age > [ttl]) or empty, fetches from [networkFetch].
  /// 5. Emits the fresh network data and updates local memory and disk cache.
  /// 6. If network fetch fails while serving stale data, logs the error and gracefully keeps
  ///    cached data displayed.
  Stream<CacheResponse<T>> watch<T>({
    required String key,
    required Duration ttl,
    required Future<T> Function() networkFetch,
    required T Function(String rawJson) fromJson,
    required String Function(T data) toJson,
    bool Function(T data)? guard,
    bool forceRefresh = false,
    bool enableLogging = true,
  }) async* {
    void log(String message) {
      if (enableLogging) debugPrint('📦 [CacheManager:$key] $message');
    }

    if (!forceRefresh) {
      // 1. Check L1 Memory Cache
      final memEntry = _memoryCache[key];
      if (memEntry != null && memEntry.data is T) {
        final data = memEntry.data as T;
        if (guard != null && !guard(data)) {
          log('⚠️ L1 Memory cache failed guard validation (e.g. grade/user mismatch). Invalidating entry and skipping cache.');
          _memoryCache.remove(key);
        } else {
          final age = DateTime.now().difference(memEntry.timestamp);
          final isStale = age > ttl;

          log('L1 Memory cache HIT (age: ${age.inSeconds}s, TTL: ${ttl.inSeconds}s).');
          yield CacheResponse<T>(
            data: data,
            source: CacheSource.memory,
            isStale: isStale,
          );

          if (!isStale) {
            log('✅ Cache is FRESH. Returning immediately (0ms network).');
            return;
          }

          log('⏳ Cache is STALE (${age.inSeconds}s old > ${ttl.inSeconds}s TTL). Triggering SILENT background re-fetch...');
          try {
            final freshData = await networkFetch();
            await save<T>(key: key, data: freshData, toJson: toJson);
            log('🔄 Silent background re-fetch SUCCEEDED. Updated cache & UI.');
            yield CacheResponse<T>(
              data: freshData,
              source: CacheSource.network,
              isStale: false,
            );
          } catch (e) {
            log('⚠️ Silent background re-fetch FAILED: $e. Gracefully preserving cached data.');
            yield CacheResponse<T>(
              data: data,
              source: CacheSource.memory,
              isStale: true,
              backgroundError: e,
            );
          }
          return;
        }
      }

      // 2. Check L2 Disk Storage
      final storage = await _getStorage();
      final raw = await storage.getString(key);
      final rawTime = await storage.getString(_timeKey(key));

      if (raw != null && raw.isNotEmpty) {
        try {
          final cachedData = fromJson(raw);
          if (guard != null && !guard(cachedData)) {
            log('⚠️ L2 Disk cache failed guard validation (e.g. grade/user mismatch). Clearing invalid entry.');
            await invalidate(key);
          } else {
            final timestamp = rawTime != null
                ? DateTime.tryParse(rawTime) ?? DateTime.now()
                : DateTime.now();
            final age = DateTime.now().difference(timestamp);
            final isStale = age > ttl;

            // Warm up L1 Memory Cache
            _memoryCache[key] = _MemoryCacheEntry(
              data: cachedData,
              timestamp: timestamp,
            );

            log('L2 Disk cache HIT (age: ${age.inSeconds}s, TTL: ${ttl.inSeconds}s).');
            yield CacheResponse<T>(
              data: cachedData,
              source: CacheSource.disk,
              isStale: isStale,
            );

            if (!isStale) {
              log('✅ Disk cache is FRESH. Returning immediately (0ms network).');
              return;
            }

            log('⏳ Disk cache is STALE (${age.inSeconds}s old > ${ttl.inSeconds}s TTL). Triggering SILENT background re-fetch...');
            try {
              final freshData = await networkFetch();
              await save<T>(key: key, data: freshData, toJson: toJson);
              log('🔄 Silent background re-fetch SUCCEEDED. Updated cache & UI.');
              yield CacheResponse<T>(
                data: freshData,
                source: CacheSource.network,
                isStale: false,
              );
            } catch (e) {
              log('⚠️ Silent background re-fetch FAILED: $e. Gracefully preserving cached data.');
              yield CacheResponse<T>(
                data: cachedData,
                source: CacheSource.disk,
                isStale: true,
                backgroundError: e,
              );
            }
            return;
          }
        } catch (deserializationError) {
          log('⚠️ Corrupted disk cache detected for key "$key". Clearing invalid entry: $deserializationError');
          await invalidate(key);
        }
      }
    }

    // 3. Cache MISS or forceRefresh: Fetch from remote network
    log(forceRefresh
        ? '🔄 Force refresh: Bypassing cache, fetching from network...'
        : '🚀 Cache is EMPTY (first run). Fetching from network...');

    try {
      final freshData = await networkFetch();
      await save<T>(key: key, data: freshData, toJson: toJson);
      log('✅ Network fetch SUCCEEDED and persisted to memory & disk.');
      yield CacheResponse<T>(
        data: freshData,
        source: CacheSource.network,
        isStale: false,
      );
    } catch (networkError) {
      log('❌ Network fetch FAILED: $networkError.');
      rethrow;
    }
  }

  /// Single-shot asynchronous get with SWR pattern.
  /// If cached, returns immediately and triggers a background revalidation if stale.
  /// If empty or fails [guard], waits for [networkFetch].
  Future<T> get<T>({
    required String key,
    required Duration ttl,
    required Future<T> Function() networkFetch,
    required T Function(String rawJson) fromJson,
    required String Function(T data) toJson,
    bool Function(T data)? guard,
    bool forceRefresh = false,
  }) async {
    final stream = watch<T>(
      key: key,
      ttl: ttl,
      networkFetch: networkFetch,
      fromJson: fromJson,
      toJson: toJson,
      guard: guard,
      forceRefresh: forceRefresh,
    );
    return (await stream.first).data;
  }

  /// Explicitly re-fetches from network, updates memory & disk cache, and returns fresh data.
  /// Perfect for Pull-to-Refresh handlers.
  Future<T> fetchAndCache<T>({
    required String key,
    required Future<T> Function() networkFetch,
    required String Function(T data) toJson,
  }) async {
    final freshData = await networkFetch();
    await save<T>(key: key, data: freshData, toJson: toJson);
    return freshData;
  }

  /// Directly retrieves the currently cached data without making any network calls.
  /// Returns `null` if no valid cache exists or if it fails [guard].
  Future<T?> getCached<T>({
    required String key,
    required T Function(String rawJson) fromJson,
    bool Function(T data)? guard,
  }) async {
    final mem = _memoryCache[key];
    if (mem != null && mem.data is T) {
      final data = mem.data as T;
      if (guard != null && !guard(data)) {
        _memoryCache.remove(key);
      } else {
        return data;
      }
    }
    final storage = await _getStorage();
    final raw = await storage.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final parsed = fromJson(raw);
      if (guard != null && !guard(parsed)) {
        await invalidate(key);
        return null;
      }
      _memoryCache[key] = _MemoryCacheEntry(
        data: parsed,
        timestamp: DateTime.now(),
      );
      return parsed;
    } catch (_) {
      return null;
    }
  }

  /// Explicitly writes data to L1 memory and L2 disk cache.
  Future<void> save<T>({
    required String key,
    required T data,
    required String Function(T data) toJson,
  }) async {
    final now = DateTime.now();
    _memoryCache[key] = _MemoryCacheEntry(data: data, timestamp: now);

    final storage = await _getStorage();
    await storage.setString(key, toJson(data));
    await storage.setString(_timeKey(key), now.toIso8601String());

    if (!_trackedKeys.contains(key)) {
      _trackedKeys.add(key);
      await storage.setString(_trackedKeysStorageKey, _trackedKeys.join(','));
    }
  }

  /// Removes a cached key from both memory and disk.
  Future<void> invalidate(String key) async {
    _memoryCache.remove(key);
    final storage = await _getStorage();
    await storage.remove(key);
    await storage.remove(_timeKey(key));

    if (_trackedKeys.remove(key)) {
      await storage.setString(_trackedKeysStorageKey, _trackedKeys.join(','));
    }
  }

  /// Clears the entire in-memory cache.
  void clearMemoryCache() {
    _memoryCache.clear();
  }

  /// Clears all CacheManager data from memory and all cached resource keys from disk.
  /// NOTE: This only purges CacheManager payloads and intentionally preserves user settings
  /// and navigation flags such as [StorageKeys.hasSeenOnboarding].
  Future<void> clearAll() async {
    _memoryCache.clear();
    final storage = await _getStorage();

    final rawTracked = await storage.getString(_trackedKeysStorageKey);
    if (rawTracked != null && rawTracked.isNotEmpty) {
      _trackedKeys.addAll(rawTracked.split(',').where((k) => k.isNotEmpty));
    }

    for (final key in _trackedKeys) {
      await storage.remove(key);
      await storage.remove(_timeKey(key));
    }
    _trackedKeys.clear();
    await storage.remove(_trackedKeysStorageKey);

    // Defensively purge standard domain cache keys
    await storage.remove(StorageKeys.examDashboardCache);
    await storage.remove(_timeKey(StorageKeys.examDashboardCache));
    await storage.remove(StorageKeys.notesSubjectsCache);
    await storage.remove(_timeKey(StorageKeys.notesSubjectsCache));
    await storage.remove(StorageKeys.profileCache);
    await storage.remove(_timeKey(StorageKeys.profileCache));
  }
}
