part of music_page;

const CATEGORY_PADDING = EdgeInsets.only(
  bottom: 64,
  left: 8,
  right: 8,
);

String generateItemGroupKey(String itemName) {
  /// TODO: This only supports english language,
  ///       will need to incorporate support for other languages.
  const alphabet = "abcdefghijklmnoprstuvwxyz";
  const articles = ["the ", "an ", "a "];

  if (itemName.isEmpty) return "#";

  /// NOTE: Observed quirks of zune when rendering the list of albums:
  ///       [IMPLEMENTED]
  ///       1. Albums starting with ["the", "a"] articles are sorted by
  ///          the second word in the title e.g:
  ///          "The Very Best of Sting" -> ["V"] not ["T"].
  ///       2. Tracks with unknown album are sorted right after ["#"] tag.
  ///       3. Albums in cyrillic are sorted after ["W"] tag if the font is
  ///          parsed by the player. Otherwise, font is converted into special characters
  ///          and sorted based on, what I can assume, relative ASCII value.
  ///
  final firstAlbumChar = itemName.toLowerCase()[0];

  final foundArticleAtIndex = articles.indexWhere(
    (article) => itemName.toLowerCase().indexOf(article) == 0,
  );

  /// NOTE: This is default logic for the group of albums:
  ///       If first letter in album name is part of the alphabet, return the key.
  ///       Otherwise, return the "#" symbol
  String groupKey = alphabet.contains(firstAlbumChar) ? firstAlbumChar : "#";
  if (foundArticleAtIndex != -1) {
    final itemNameWithoutLeadingArticle =
        itemName.substring(articles[foundArticleAtIndex].length).trim()[0];
    groupKey = alphabet.contains(itemNameWithoutLeadingArticle.toLowerCase())
        ? itemNameWithoutLeadingArticle
        : "#";
  }

  return groupKey;
}

/// NOTE: Method responsible for generating item alphabetical groups based on a string key.
///       List<Item> items - List of items e.g. albums/genres
///       ItemGroup Function(String? groupKey, Item? item) groupBuilder - Tuple group generator
///        String Function(Item item) groupKeyGenerator - Group key generator
List<ItemGroup> generateItemGroups<Item, ItemGroup>(
  List<Item> items,
  ItemGroup Function(String? groupKey, Item? item) groupBuilder,
  String Function(Item item) groupKeyGenerator,
) {
  if (items.isEmpty) return [];

  final LinkedHashMap<String, List<Item>> map = LinkedHashMap();

  // "#" group key goes first and represents items starting with a number
  map.putIfAbsent("#", () => []);

// Build a Linked Hash Map of a keys and their respective item groups
  for (final item in items) {
    final groupKey = groupKeyGenerator(item);
    if (map.containsKey(groupKey)) {
      map[groupKey]!.add(item);
    } else {
      map.putIfAbsent(groupKey, () => [item]);
    }
  }

  // "." group key goes last represents items starting with punctuation
  // TODO: Might not be actually correctly implemented...
  map.putIfAbsent(".", () => []);

// Reduce the map to a Item Group where first entry is a group key configuration
// and the rest in a group are the items under said group
// e.g. all albums starting with letter "a"
  final result = <ItemGroup>[];
  String? previousGroupKey;
  for (final entry in map.entries) {
    final groupKey = entry.key;
    final groupItems = entry.value;
    if (previousGroupKey != groupKey) {
      result.add(groupBuilder(groupKey, null));
      previousGroupKey = groupKey;
    }
    for (final item in groupItems) {
      result.add(groupBuilder(null, item));
    }
  }
  return result;
}
