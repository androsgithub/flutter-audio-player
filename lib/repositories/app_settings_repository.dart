import 'package:audio_player/services/shared_preferences_service.dart';

class AppSettingsRepository {
  final SharedPreferencesService _prefs = SharedPreferencesService();

  setPaths(List<String> paths) async {
    await _prefs.setStringList('paths', paths);
  }

  Future<List<String>> getPaths() async {
    return await _prefs.getStringList('paths');
  }

  setVolume(double volume) async {
    await _prefs.setDouble('video_player_volume', volume);
  }

  Future<double> getVolume() async {
    return await _prefs.getDouble('video_player_volume');
  }
}
