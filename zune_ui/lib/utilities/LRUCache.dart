part of utilities;

/// A simple LRU (Least Recently Used) cache implementation.
///
/// When the cache reaches [maxSize], the least recently used entry
/// is evicted when a new entry is added.
class LRUCache<K, V> {
  final int maxSize;
  final LinkedHashMap<K, V> _cache = LinkedHashMap<K, V>();

  LRUCache({required this.maxSize})
      : assert(maxSize > 0, 'maxSize must be greater than 0');

  /// Returns the number of entries in the cache.
  int get length => _cache.length;

  /// Returns true if the cache is empty.
  bool get isEmpty => _cache.isEmpty;

  /// Returns true if the cache is not empty.
  bool get isNotEmpty => _cache.isNotEmpty;

  /// Checks if the cache contains the given key.
  bool containsKey(K key) {
    if (_cache.containsKey(key)) {
      // Move to end (most recently used) by removing and re-adding
      final value = _cache.remove(key)!;
      _cache[key] = value;
      return true;
    }
    return false;
  }

  /// Gets the value for the given key, or null if not found.
  /// Accessing a key moves it to the most recently used position.
  V? operator [](K key) {
    if (_cache.containsKey(key)) {
      // Move to end (most recently used) by removing and re-adding
      final value = _cache.remove(key)!;
      _cache[key] = value;
      return value;
    }
    return null;
  }

  /// Sets the value for the given key.
  /// If the cache is at max size, the least recently used entry is evicted.
  void operator []=(K key, V value) {
    if (_cache.containsKey(key)) {
      // Update existing: remove and re-add to mark as recently used
      _cache.remove(key);
    } else if (_cache.length >= maxSize) {
      // Evict least recently used (first entry in LinkedHashMap)
      _cache.remove(_cache.keys.first);
    }
    // Add to end (most recently used)
    _cache[key] = value;
  }

  /// Clears all entries from the cache.
  void clear() {
    _cache.clear();
  }
}
