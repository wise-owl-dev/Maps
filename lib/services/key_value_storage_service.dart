// lib/features/shared/infrastructure/services/key_value_storage_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KeyValueStorageService {
  Future<SharedPreferences> getSharedPrefs() async {
    return await SharedPreferences.getInstance();
  }

  Future<void> setKeyValue(String key, dynamic value) async {
    final prefs = await getSharedPrefs();

    switch (value.runtimeType) {
      case String:
        prefs.setString(key, value);
        break;
      case int:
        prefs.setInt(key, value);
        break;
      case bool:
        prefs.setBool(key, value);
        break;
      case double:
        prefs.setDouble(key, value);
        break;
      default:
        throw UnimplementedError('Type not supported');
    }
  }

  Future<dynamic> getValue(String key) async {
    final prefs = await getSharedPrefs();
    return prefs.get(key);
  }

  Future<void> removeKey(String key) async {
    final prefs = await getSharedPrefs();
    await prefs.remove(key);
  }
}

final keyValueStorageProvider = Provider<KeyValueStorageService>((ref) {
  return KeyValueStorageService();
});