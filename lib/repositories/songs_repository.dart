import 'dart:io';

import 'package:audio_player/model/local_song_model.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SongsRepository {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  SongsRepository();

  Future<Iterable<SongModel>> getSongs({String path = ""}) async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      List<FileSystemEntity> files = Directory(path).listSync();

      return files
          .where((string) => string.path.endsWith(".mp3"))
          .map((file) => SongModel({
                'title': file.path
                    .replaceAll(".mp3", "")
                    .split('/')
                    .last
                    .split('\\')
                    .last
                    .toString(),
                '_data': file.path,
                'artist': '<unknown>'
              }));
    } else {
      var files = await _audioQuery.querySongs();
      return files
          .where(((file) => file.isAlarm == false))
          .where(((file) => file.isNotification == false))
          .where(((file) => file.isRingtone == false))
          .toList();
    }
  }
}
