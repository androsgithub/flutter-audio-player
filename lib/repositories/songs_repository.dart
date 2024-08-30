import 'package:audio_player/model/song_model.dart';
import 'dart:io';

class SongsRepository {
  SongsRepository();

  Iterable<SongModel> getSongs(String path) {
    //recursive: true, followLinks: false to smartphones
    List files = Directory(path).listSync();

    return files.where((string) => string.path.endsWith(".mp3")).map(
        (file) => SongModel.simples(file.path.split('\\').last, file.path));
  }
}
