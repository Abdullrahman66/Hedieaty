import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  
  static final SharedPrefsHelper _instance = SharedPrefsHelper._internal();

  SharedPreferences? _prefs;

  SharedPrefsHelper._internal();

  factory SharedPrefsHelper() => _instance;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs?.reload();
  }
  

  Future<bool> putString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }


  Future<bool> putInt(String key, int value) async {
    return await _prefs?.setInt(key, value) ?? false;
  }

  
  Future<bool> putBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  
  String? getString(String key) {
    return _prefs?.getString(key);
  }

 
  int? getInt(String key) {
    return _prefs?.getInt(key);
  }

 
  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  
  Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  
  Map<String, dynamic> getAll() {
    final keys = _prefs?.getKeys() ?? {};
    final Map<String, dynamic> allData = {};

    for (var key in keys) {
      allData[key] = _prefs?.get(key); 
    }

    return allData;
  }

  
  bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }


  Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }
}
