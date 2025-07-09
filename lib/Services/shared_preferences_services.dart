import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const String _platformsKey = 'selected_platforms';
  static const String _firstTimeKey = 'first_time';

  final SharedPreferences _prefs;

  SharedPreferencesService(this._prefs);

  Future<bool> hasSelectedPlatforms() async {
    return _prefs.containsKey(_platformsKey);
  }

  Future<List<int>?> getSelectedPlatforms() async {
    final String? platformsString = _prefs.getString(_platformsKey);
    if (platformsString == null || platformsString.isEmpty) return null;

    try {
      return platformsString.split(',').map(int.parse).toList();
    } catch (e) {
      return null;
    }
  }

  Future<void> setSelectedPlatforms(List<int> platforms) async {
    await _prefs.setString(_platformsKey, platforms.join(','));
    await _prefs.setBool(_firstTimeKey, false);
  }

  Future<void> clearSelectedPlatforms() async {
    await _prefs.remove(_platformsKey);
  }
}
