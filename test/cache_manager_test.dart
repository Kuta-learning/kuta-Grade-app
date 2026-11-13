import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuta_grade/core/cache/cache_manager.dart';
import 'package:kuta_grade/core/cache/cache_response.dart';
import 'package:kuta_grade/core/storage/local_storage.dart';

class FakeLocalStorage implements LocalStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> setString(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<String?> getString(String key) async {
    return _data[key];
  }

  @override
  Future<void> remove(String key) async {
    _data.remove(key);
  }

  @override
  Future<void> clear() async {
    _data.clear();
  }
}

class SampleItem {
  final String title;
  final int count;

  const SampleItem(this.title, this.count);

  factory SampleItem.fromJson(Map<String, dynamic> json) =>
      SampleItem(json['title'] as String, json['count'] as int);

  Map<String, dynamic> toJson() => {'title': title, 'count': count};

  String toJsonString() => jsonEncode(toJson());

  static SampleItem fromJsonString(String raw) =>
      SampleItem.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}

void main() {
  group('CacheManager Unit Tests', () {
    late FakeLocalStorage storage;
    late CacheManager cacheManager;

    setUp(() {
      storage = FakeLocalStorage();
      cacheManager = CacheManager(storage: storage);
    });

    test('1. First run (empty cache) fetches from network and caches result', () async {
      int networkCalls = 0;
      Future<SampleItem> mockNetwork() async {
        networkCalls++;
        return const SampleItem('Exam Physics', 10);
      }

      final responses = await cacheManager
          .watch<SampleItem>(
            key: 'test_item',
            ttl: const Duration(minutes: 5),
            networkFetch: mockNetwork,
            fromJson: SampleItem.fromJsonString,
            toJson: (item) => item.toJsonString(),
            enableLogging: false,
          )
          .toList();

      expect(responses.length, 1);
      expect(responses.first.source, CacheSource.network);
      expect(responses.first.data.title, 'Exam Physics');
      expect(networkCalls, 1);

      // Verify it was persisted to disk storage
      final diskRaw = await storage.getString('test_item');
      expect(diskRaw, isNotNull);
      expect(diskRaw, contains('Exam Physics'));
    });

    test('2. Cache HIT when FRESH (< TTL) emits cached data and skips network', () async {
      // Pre-seed disk cache with recent timestamp
      const item = SampleItem('Cached Math', 25);
      await cacheManager.save<SampleItem>(
        key: 'math_key',
        data: item,
        toJson: (m) => m.toJsonString(),
      );

      int networkCalls = 0;
      Future<SampleItem> mockNetwork() async {
        networkCalls++;
        return const SampleItem('Fresh Math', 30);
      }

      final responses = await cacheManager
          .watch<SampleItem>(
            key: 'math_key',
            ttl: const Duration(minutes: 5),
            networkFetch: mockNetwork,
            fromJson: SampleItem.fromJsonString,
            toJson: (m) => m.toJsonString(),
            enableLogging: false,
          )
          .toList();

      expect(responses.length, 1);
      expect(responses.first.source, CacheSource.memory);
      expect(responses.first.data.title, 'Cached Math');
      expect(responses.first.isStale, false);
      expect(networkCalls, 0); // Network call was skipped!
    });

    test('3. Cache HIT when STALE (> TTL) emits cached first, then emits fresh network data', () async {
      // Pre-seed storage with an old timestamp (10 minutes ago)
      const oldItem = SampleItem('Old Biology', 5);
      await storage.setString('bio_key', oldItem.toJsonString());
      await storage.setString(
        'bio_key:timestamp',
        DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
      );

      int networkCalls = 0;
      Future<SampleItem> mockNetwork() async {
        networkCalls++;
        return const SampleItem('Updated Biology', 12);
      }

      final responses = await cacheManager
          .watch<SampleItem>(
            key: 'bio_key',
            ttl: const Duration(minutes: 5),
            networkFetch: mockNetwork,
            fromJson: SampleItem.fromJsonString,
            toJson: (b) => b.toJsonString(),
            enableLogging: false,
          )
          .toList();

      expect(responses.length, 2);

      // First emission: Stale cached data from disk
      expect(responses[0].source, CacheSource.disk);
      expect(responses[0].isStale, true);
      expect(responses[0].data.title, 'Old Biology');

      // Second emission: Fresh revalidated data from network
      expect(responses[1].source, CacheSource.network);
      expect(responses[1].isStale, false);
      expect(responses[1].data.title, 'Updated Biology');

      expect(networkCalls, 1);
    });

    test('4. Cache HIT when STALE with network failure gracefully keeps cached data', () async {
      // Pre-seed storage with an old timestamp
      const oldItem = SampleItem('Offline Chemistry', 8);
      await storage.setString('chem_key', oldItem.toJsonString());
      await storage.setString(
        'chem_key:timestamp',
        DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
      );

      Future<SampleItem> failingNetwork() async {
        throw Exception('No internet connection');
      }

      final responses = await cacheManager
          .watch<SampleItem>(
            key: 'chem_key',
            ttl: const Duration(minutes: 5),
            networkFetch: failingNetwork,
            fromJson: SampleItem.fromJsonString,
            toJson: (c) => c.toJsonString(),
            enableLogging: false,
          )
          .toList();

      expect(responses.length, 2);

      // First emission: Stale cached data
      expect(responses[0].source, CacheSource.disk);
      expect(responses[0].isStale, true);
      expect(responses[0].data.title, 'Offline Chemistry');

      // Second emission: Cached data preserved with background error attached
      expect(responses[1].isStale, true);
      expect(responses[1].data.title, 'Offline Chemistry');
      expect(responses[1].backgroundError, isNotNull);
    });

    test('5. Invalidate removes entry from both memory and disk', () async {
      const item = SampleItem('English', 15);
      await cacheManager.save<SampleItem>(
        key: 'eng_key',
        data: item,
        toJson: (e) => e.toJsonString(),
      );

      await cacheManager.invalidate('eng_key');

      final cached = await cacheManager.getCached<SampleItem>(
        key: 'eng_key',
        fromJson: SampleItem.fromJsonString,
      );
      expect(cached, isNull);
      expect(await storage.getString('eng_key'), isNull);
    });
  
    test('6. Guard validation failure discards mismatched cache and fetches fresh data', () async {
      const cachedItem = SampleItem('Grade 12 Item', 12);
      await cacheManager.save<SampleItem>(
        key: 'grade_key',
        data: cachedItem,
        toJson: (m) => m.toJsonString(),
      );

      int networkCalls = 0;
      Future<SampleItem> mockNetwork() async {
        networkCalls++;
        return const SampleItem('Grade 8 Fresh Item', 8);
      }

      final responses = await cacheManager
          .watch<SampleItem>(
            key: 'grade_key',
            ttl: const Duration(minutes: 10),
            networkFetch: mockNetwork,
            fromJson: SampleItem.fromJsonString,
            toJson: (m) => m.toJsonString(),
            guard: (item) => item.count == 8,
            enableLogging: false,
          )
          .toList();

      expect(responses.length, 1);
      expect(responses.first.source, CacheSource.network);
      expect(responses.first.data.title, 'Grade 8 Fresh Item');
      expect(responses.first.data.count, 8);
      expect(networkCalls, 1);
    });
  });
}