part of playlist_list_widget;

class PlaylistList extends StatefulWidget {
  const PlaylistList({
    super.key,
  });

  @override
  State<PlaylistList> createState() => _PlaylistListState();
}

class _PlaylistListState extends State<PlaylistList> {
  @override
  Widget build(BuildContext context) {
    return ListWrapper<UnmodifiableListView<PlaylistSummary>, PlaylistSummary,
        PlaylistSummary>(
      selector: (state) => state.allPlaylists,
      itemBuilder: (context, playlist) => PlaylistListTile(playlist: playlist),
    );
  }
}
