import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  SharedPreferencesService();

  Future<String> getString(String name) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString(name) ?? "";
  }

  Future<bool> getBool(String name) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getBool(name) ?? false;
  }

  Future<double> getDouble(String name) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(name) ?? 0;
  }

  Future<void> setDouble(String name, double number) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setDouble(name, number);
  }

  Future<List<String>> getStringList(String name) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(name) ?? [];
  }

  Future<void> setStringList(String name, List<String> list) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setStringList(name, list);
  }
}
