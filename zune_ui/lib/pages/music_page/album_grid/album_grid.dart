part of album_grid_widget;

class AlbumsGrid extends StatefulWidget {
  const AlbumsGrid({
    super.key,
  });

  @override
  State<AlbumsGrid> createState() => _AlbumsGridState();
}

String _getGroupKey(String albumName) {
  /// TODO: This only supports english language,
  ///       will need to incorporate support for other languages.
  const alphabet = "abcdefghijklmnoprstuvwxyz";
  const articles = ["the ", "an ", "a "];

  if (albumName.isEmpty) return "#";

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
  final firstAlbumChar = albumName.toLowerCase()[0];

  final foundArticleAtIndex = articles.indexWhere(
    (article) => albumName.toLowerCase().indexOf(article) == 0,
  );

  /// NOTE: This is default logic for the group of albums:
  ///       If first letter in album name is part of the alphabet, return the key.
  ///       Otherwise, return the "#" symbol
  String groupKey = alphabet.contains(firstAlbumChar) ? firstAlbumChar : "#";
  if (foundArticleAtIndex != -1) {
    final albumNameWithoutLeadingArticle =
        albumName.substring(articles[foundArticleAtIndex].length).trim()[0];
    groupKey = alphabet.contains(albumNameWithoutLeadingArticle)
        ? albumNameWithoutLeadingArticle
        : "#";
  }

  return groupKey;
}

List<({String? groupKey, AlbumSummary? album})> _generateAlbumGroups(
    List<AlbumSummary> albums) {
  final result = <({String? groupKey, AlbumSummary? album})>[];

  String? previousGroupKey;
  for (final album in albums) {
    final groupKey = _getGroupKey(album.album_name);

    /// NOTE: Keep track of the group key matching the previous group key,
    ///       if there is mismatch, add new group key object and update previous key
    ///       to the current one.
    if (previousGroupKey != groupKey) {
      result.add((groupKey: groupKey, album: null));
      previousGroupKey = groupKey;
    }

    result.add((groupKey: null, album: album));
  }

  result.insert(0, (groupKey: "#", album: null));
  result.add((groupKey: ".", album: null));

  return result;
}

class _AlbumsGridState extends State<AlbumsGrid> {
  @override
  Widget build(BuildContext context) {
    return Selector<GlobalModalState, UnmodifiableListView<AlbumSummary>>(
      selector: (context, state) => state.allAlbums,
      builder: (context, albums, child) {
        final albumGroups = _generateAlbumGroups(albums);

        /// NOTE: Using ListView separated her in order to configure
        ///       spaced out list item vertical view.
        return OverScrollWrapper(
          /// NOTE: This should lazy load if there are many albums.
          builder: (scrollController, scrollPhysics) => GridView.builder(
            // Over scroll props:
            controller: scrollController,
            physics: scrollPhysics,
            // GridView props:
            padding: parent.CATEGORY_PADDING,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 20.0,
              mainAxisSpacing: 24,
              childAspectRatio: 1,
            ),
            itemCount: albumGroups.length,
            itemBuilder: (context, index) => AlbumsGridTile(
              albumGroup: albumGroups[index],
            ),
          ),
        );
      },
    );
  }
}
