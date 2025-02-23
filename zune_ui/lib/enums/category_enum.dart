part of enums;

enum MusicCategoryType {
  albums("albums"),
  artists("artists"),
  playlists("playlists"),
  songs("songs"),
  genres("genres");

  final String name;
  String get displayName => name.toUpperCase();
  const MusicCategoryType(this.name);

  static MusicCategoryType getNextPrevCategory(
      int delta, MusicCategoryType current) {
    final shouldGoToNextCategory = delta > 0;
    const values = MusicCategoryType.values;
    final index = values.indexOf(current);
    final nextIndex = index + (shouldGoToNextCategory ? 1 : -1);

    if (nextIndex < 0) {
      return values[values.length - 1];
    } else if (nextIndex > values.length - 1) {
      return values[0];
    }
    return values[nextIndex];
  }

  static List<String> categoriesStartingAt(
      {MusicCategoryType type = MusicCategoryType.albums}) {
    final values = MusicCategoryType.values.map((e) => e.displayName).toList();
    final index = MusicCategoryType.values.indexOf(type);

    return [
      ...values.getRange(index, values.length),
      ...values.getRange(0, index),
    ];
  }

  static int getMusicDeltaChange(
      MusicCategoryType prev, MusicCategoryType current) {
    final list = MusicCategoryType.categoriesStartingAt(type: prev);
    final currentIndex = list.indexOf(current.displayName);

    final change = currentIndex == list.length - 1 ? -1 : currentIndex;
    return change == 0
        ? 0
        : change > 0
            ? 1
            : -1;
  }
}
