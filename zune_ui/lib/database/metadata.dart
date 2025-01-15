import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';

class Metadata {
  final String musicFolder;
  List<AudioMetadata> files = [];

  Metadata(this.musicFolder) {
    initialize();
  }

  void initialize() {
    var folder = Directory(
            "${Directory.current.path.split('zune_ui').first}\\$musicFolder")
        .listSync(recursive: true)
        .whereType<File>()
        .where((element) =>
            element.path.contains("mp4") ||
            element.path.contains("m4a") ||
            element.path.contains("mp3") ||
            element.path.contains("flac"))
        .toList();

    for (final file in folder) {
      files.add(readMetadata(file, getImage: true));
    }
  }
}
