/// Source from which cached data was loaded.
enum CacheSource {
  /// Loaded instantaneously from L1 in-memory map (0ms).
  memory,

  /// Loaded from L2 persistent local disk storage (e.g. SharedPreferences).
  disk,

  /// Fetched live from remote backend over network.
  network,
}

/// Represents the data emitted by [CacheManager] along with its cache metadata.
class CacheResponse<T> {
  /// The payload data.
  final T data;

  /// The layer where [data] was loaded from.
  final CacheSource source;

  /// True if the data was served from cache but its TTL has expired,
  /// indicating a background revalidation was triggered.
  final bool isStale;

  /// Non-null if background revalidation failed, allowing the caller to show a non-intrusive warning
  /// while still keeping [data] displayed.
  final Object? backgroundError;

  const CacheResponse({
    required this.data,
    required this.source,
    this.isStale = false,
    this.backgroundError,
  });

  @override
  String toString() =>
      'CacheResponse(source: $source, isStale: $isStale, data: $data, backgroundError: $backgroundError)';
}

