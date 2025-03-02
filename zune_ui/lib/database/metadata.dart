part of database;

class Metadata {
  final String? musicFolder;
  List<AudioMetadata> files = [];

  Metadata({
    this.musicFolder = "Zune Music",
  }) {
    initialize();
  }

  Future<void> initialize() async {
    /// NOTE: Creating the directory if it doesn't exist
    ///       One can't simply create folders in OS, so using this for now:
    ///       -> https://pub.dev/packages/path_provider
    final appDir = await getApplicationDocumentsDirectory();
    final directoryPath = "${appDir.path}/$musicFolder";

    console.log("Directory path: $directoryPath", customTags: ["DIRECTORY"]);

    final directory = Directory(directoryPath);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);

      // There will be no files in this directory
      // So returning
      return;
    }

    // Hack: to keep order of the songs
    compare(File a, File b) => a.path.compareTo(b.path);
    var folder = Directory(directoryPath)
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (element) =>
              element.path.contains("mp4") ||
              element.path.contains("m4a") ||
              element.path.contains("mp3") ||
              element.path.contains("flac"),
        )
        .sorted(compare)
        .toList();

    for (final file in folder) {
      files.add(readMetadata(file, getImage: true));
    }
  }
}
