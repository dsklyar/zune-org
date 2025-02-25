import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';

class Metadata {
  final String? musicFolder;
  List<AudioMetadata> files = [];

  Metadata({
    this.musicFolder = "music_dir",
  }) {
    initialize();
  }

  void initialize() {
    /// TODO: Need to figure out a wau to auto create folder if does not exist
    /// NOTE: It seems that Directory.current is not the best way to get the path
    ///       https://github.com/flutter/flutter/issues/135740
    final root = Platform.environment['PWD']?.split('zune_ui').first ??
        Directory.current.path.split('zune_ui').first;
    var folder = Directory("$root$musicFolder")
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
