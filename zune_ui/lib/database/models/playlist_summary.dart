part of database;

class PlaylistSummaryColumns extends PlaylistModelColumns {
  const PlaylistSummaryColumns();
  String get track_ids => "track_ids";
  @override
  List<String> get values => [
        track_ids,
        ...super.values,
      ];
}

class PlaylistSummary extends PlaylistModel {
  static const PlaylistSummaryColumns columns = PlaylistSummaryColumns();

  final List<int> track_ids;

  PlaylistSummary({
    this.track_ids = const [],
    required super.playlist_name,
  });

  PlaylistSummary.fromJson(Map<String, Object?> json)
      : track_ids = (json[columns.track_ids] as String)
            .split(",")
            .map(int.parse)
            .toList(),
        super.fromJson(json);

  static Future<List<PlaylistSummary>> readAll({
    WhereClause? where,
  }) async {
    final ZuneDatabase zune = ZuneDatabase.instance;

    final db = await zune.database;
    final result = await db.rawQuery('''
      SELECT
        playlists.*,
        GROUP_CONCAT(ordered_tracks.${PlaylistTrackJunction.columns.track_id}) AS ${PlaylistSummary.columns.track_ids}
      FROM
        ${PlaylistModel.tableName} playlists
      LEFT JOIN (
        SELECT
          ${PlaylistTrackJunction.columns.playlist_id},
          ${PlaylistTrackJunction.columns.track_id}
        FROM
          ${PlaylistTrackJunction.tableName}
        ORDER BY 
          ${PlaylistTrackJunction.columns.track_order}
      ) AS ordered_tracks
      ON
        playlists.${PlaylistModel.columns.playlist_id} = ordered_tracks.${PlaylistTrackJunction.columns.playlist_id}
      ${where != null ? "WHERE ${columns.toSqlClause(where)}" : ''}
      GROUP BY
        playlists.${PlaylistModel.columns.playlist_id}, playlists.${PlaylistModel.columns.playlist_name};
    ''');

    return result
        .map(
          (json) => PlaylistSummary.fromJson(json),
        )
        .toList();
  }
}
