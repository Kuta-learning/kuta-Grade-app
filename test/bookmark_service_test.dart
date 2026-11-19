import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuta_grade/core/cache/cache_manager.dart';
import 'package:kuta_grade/core/storage/local_storage.dart';
import 'package:kuta_grade/core/storage/storage_keys.dart';
import 'package:kuta_grade/features/grades/models/bookmark_model.dart';
import 'package:kuta_grade/features/grades/screens/bookmarks_screen.dart';
import 'package:kuta_grade/features/grades/services/bookmark_service.dart';

class _FakeLocalStorage implements LocalStorage {
  final Map<String, String> data = {};

  @override
  Future<void> setString(String key, String value) async => data[key] = value;

  @override
  Future<String?> getString(String key) async => data[key];

  @override
  Future<void> remove(String key) async => data.remove(key);

  @override
  Future<void> clear() async => data.clear();
}

class _FakeBookmarkService extends BookmarkService {
  List<BookmarkItem> mockBookmarks;
  bool toggleCalled = false;
  bool deleteCalled = false;

  _FakeBookmarkService({
    this.mockBookmarks = const [],
    super.cacheManager,
  });

  @override
  Future<List<BookmarkItem>> getBookmarks({
    String? type,
    String? subjectId,
    int page = 1,
    int limit = 50,
  }) async {
    return mockBookmarks;
  }

  @override
  Future<BookmarkToggleResponse> toggleBookmark({
    required String type,
    required String itemId,
    required String title,
    String? subjectId,
    Map<String, dynamic>? metadata,
  }) async {
    toggleCalled = true;
    final exists = mockBookmarks.any((b) => b.itemId == itemId);
    if (exists) {
      mockBookmarks = mockBookmarks.where((b) => b.itemId != itemId).toList();
      return const BookmarkToggleResponse(
        isBookmarked: false,
        message: 'Bookmark removed',
      );
    } else {
      final newItem = BookmarkItem(
        id: 'new-id',
        type: type,
        itemId: itemId,
        title: title,
        subjectId: subjectId,
        metadata: metadata,
      );
      mockBookmarks = [...mockBookmarks, newItem];
      return BookmarkToggleResponse(
        isBookmarked: true,
        message: 'Bookmark added',
        bookmark: newItem,
      );
    }
  }

  @override
  Future<void> deleteBookmark(String bookmarkId) async {
    deleteCalled = true;
    mockBookmarks = mockBookmarks.where((b) => b.id != bookmarkId).toList();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    dotenv.loadFromString(envString: 'API_BASE_URL=https://test.kuta.com/api\n');
  });

  setUp(() async {
    CacheManager.instance.clearMemoryCache();
    await CacheManager.instance.invalidate(StorageKeys.bookmarksCache);
  });

  group('Bookmark Model Tests', () {
    test('BookmarkItem serializes to JSON and parses correctly', () {
      final item = BookmarkItem(
        id: 'bm-1',
        type: 'EXAM_QUESTION',
        itemId: 'exam-101',
        title: 'Grade 12 Physics - 2023 Exam',
        subjectId: 'sub-1',
        metadata: {'stream': 'NATURAL'},
        createdAt: DateTime(2026, 11, 11, 10, 0),
      );

      final json = item.toJson();
      expect(json['id'], 'bm-1');
      expect(json['type'], 'EXAM_QUESTION');
      expect(json['itemId'], 'exam-101');
      expect(json['title'], 'Grade 12 Physics - 2023 Exam');

      final reconstructed = BookmarkItem.fromJson(json);
      expect(reconstructed.id, item.id);
      expect(reconstructed.itemId, item.itemId);
      expect(reconstructed.title, item.title);
      expect(reconstructed.metadata?['stream'], 'NATURAL');
    });

    test('BookmarkItem encodeList and decodeList handles list roundtrip', () {
      final list = [
        const BookmarkItem(
          id: '1',
          type: 'EXAM_QUESTION',
          itemId: 'item-1',
          title: 'Exam 1',
        ),
        const BookmarkItem(
          id: '2',
          type: 'NOTE_CHAPTER',
          itemId: 'item-2',
          title: 'Chapter 2',
        ),
      ];

      final encoded = BookmarkItem.encodeList(list);
      final decoded = BookmarkItem.decodeList(encoded);

      expect(decoded.length, 2);
      expect(decoded[0].id, '1');
      expect(decoded[1].type, 'NOTE_CHAPTER');
    });

    test('BookmarkToggleResponse parses add and remove responses', () {
      final addJson = {
        'isBookmarked': true,
        'message': 'Bookmark added',
        'bookmark': {
          'id': 'b-1',
          'type': 'EXAM_QUESTION',
          'itemId': 'q-1',
          'title': 'Question 1',
        },
      };

      final addResponse = BookmarkToggleResponse.fromJson(addJson);
      expect(addResponse.isBookmarked, isTrue);
      expect(addResponse.message, 'Bookmark added');
      expect(addResponse.bookmark?.id, 'b-1');

      final removeJson = {
        'isBookmarked': false,
        'message': 'Bookmark removed',
        'bookmarkId': 'b-1',
      };

      final removeResponse = BookmarkToggleResponse.fromJson(removeJson);
      expect(removeResponse.isBookmarked, isFalse);
      expect(removeResponse.message, 'Bookmark removed');
      expect(removeResponse.bookmarkId, 'b-1');
    });
  });

  group('Bookmark CacheManager Integration Tests', () {
    test('BookmarkService streams from CacheManager with 1-minute TTL', () async {
      final fakeStorage = _FakeLocalStorage();
      final cacheManager = CacheManager(storage: fakeStorage);

      final fakeService = _FakeBookmarkService(
        mockBookmarks: [
          const BookmarkItem(
            id: 'b-1',
            type: 'EXAM_QUESTION',
            itemId: 'exam-1',
            title: 'Mathematics 2023',
          ),
        ],
        cacheManager: cacheManager,
      );

      final stream = fakeService.streamBookmarks(
        maxStale: const Duration(minutes: 1),
      );

      final firstEmit = await stream.first;
      expect(firstEmit.data.length, 1);
      expect(firstEmit.data.first.title, 'Mathematics 2023');

      // Verify data was persisted to disk cache under StorageKeys.bookmarksCache
      final rawCached = await fakeStorage.getString(StorageKeys.bookmarksCache);
      expect(rawCached, isNotNull);
      expect(rawCached!.contains('Mathematics 2023'), isTrue);
    });
  });

  group('BookmarksScreen Widget Tests', () {
    testWidgets('BookmarksScreen renders empty state when no bookmarks', (tester) async {
      final fakeService = _FakeBookmarkService(
        mockBookmarks: [],
        cacheManager: CacheManager(storage: _FakeLocalStorage()),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BookmarksScreen(service: fakeService),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No bookmarks yet'), findsOneWidget);
      expect(
        find.text(
          'Tap the bookmark icon on any exam paper or note to save it here for fast revision.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('BookmarksScreen renders bookmarked items and handles removal', (tester) async {
      final fakeService = _FakeBookmarkService(
        mockBookmarks: [
          const BookmarkItem(
            id: 'bm-test-1',
            type: 'EXAM_QUESTION',
            itemId: 'exam-100',
            title: 'Mathematics - 2023 Exam',
          ),
        ],
        cacheManager: CacheManager(storage: _FakeLocalStorage()),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BookmarksScreen(service: fakeService),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Mathematics - 2023 Exam'), findsOneWidget);
      expect(find.text('Mathematics'), findsOneWidget);
      expect(find.text('Start Exam'), findsOneWidget);

      // Tap remove bookmark icon
      final bookmarkIcon = find.byTooltip('Remove bookmark');
      expect(bookmarkIcon, findsOneWidget);
      await tester.tap(bookmarkIcon);
      await tester.pumpAndSettle();

      expect(fakeService.deleteCalled, isTrue);
      expect(find.text('No bookmarks yet'), findsOneWidget);
    });
  });
}
