import 'dart:math';

import 'package:audio_player/model/song_model.dart';
import 'package:audio_player/repositories/app_settings_repository.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class PlayerService extends ChangeNotifier {
  AppSettingsRepository appSettingsRepository = AppSettingsRepository();
  PlayerService() {
    _iniciarPlayer();
  }
  _iniciarPlayer() async {
    await player.setVolume(await appSettingsRepository.getVolume());

    // Set the release mode to keep the source after playback has completed.
    player.setReleaseMode(ReleaseMode.stop);

    // Start the player as soon as the app is displayed.
    if (playlist.isNotEmpty) {
      setSong(playlist[songIndex].songPath);
    }

    player.onPlayerComplete.listen((event) async {
      nextSong();
      if (repeatType == RepeatType.single) {
        await player.resume();
      }
    });
    notifyListeners();
  }

  //variables
  int songIndex = 0;
  List<SongModel> playlist = [];
  RepeatType repeatType = RepeatType.linear;

  AudioPlayer player = AudioPlayer();

  changeRepeatType() {
    switch (repeatType) {
      case RepeatType.linear:
        repeatType = RepeatType.single;
        break;
      case RepeatType.single:
        repeatType = RepeatType.random;
        break;
      case RepeatType.random:
        repeatType = RepeatType.linear;
        break;
    }
    notifyListeners();
  }

  nextSong() {
    if (playlist.length == 1 || repeatType == RepeatType.single) return;

    if (songIndex >= playlist.length - 1) {
      songIndex = 0;
      return;
    }
    if (repeatType == RepeatType.random) {
      songIndex = Random().nextInt(playlist.length);
    } else {
      songIndex++;
    }

    setSong(playlist[songIndex].songPath);
    notifyListeners();
  }

  previousSong() {
    if (playlist.length == 1 || repeatType == RepeatType.single) return;

    if (songIndex <= 0) {
      songIndex = playlist.length - 1;
      return;
    }
    songIndex--;
    setSong(playlist[songIndex].songPath);
    notifyListeners();
  }

  setSong(String path) async {
    await player.setSource(DeviceFileSource(path));
    await player.resume();
    notifyListeners();
  }
}

enum RepeatType { linear, single, random }
