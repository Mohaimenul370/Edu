import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io' show Platform;
import 'dart:developer' as developer;

class PreferenceService {
  static final _secureStorage = const FlutterSecureStorage();
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // String operations
  static Future<void> setString(String key, String value) async {
    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        await _secureStorage.write(key: key, value: value);
      } else {
        await _prefs?.setString(key, value);
        await _prefs?.commit();
      }
    } catch (e) {
      developer.log('Error setting string: $e');
    }
  }

  static Future<String?> getString(String key) async {
    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        return await _secureStorage.read(key: key);
      } else {
        return _prefs?.getString(key);
      }
    } catch (e) {
      developer.log('Error getting string: $e');
      return null;
    }
  }

  // Bool operations
  static Future<void> setBool(String key, bool value) async {
    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        await _secureStorage.write(key: key, value: value.toString());
      } else {
        await _prefs?.setBool(key, value);
        await _prefs?.commit();
      }
    } catch (e) {
      developer.log('Error setting bool: $e');
    }
  }

  static Future<bool?> getBool(String key) async {
    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final value = await _secureStorage.read(key: key);
        return value?.toLowerCase() == 'true';
      } else {
        return _prefs?.getBool(key);
      }
    } catch (e) {
      developer.log('Error getting bool: $e');
      return null;
    }
  }

  // Int operations
  static Future<void> setInt(String key, int value) async {
    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        await _secureStorage.write(key: key, value: value.toString());
      } else {
        await _prefs?.setInt(key, value);
        await _prefs?.commit();
      }
    } catch (e) {
      developer.log('Error setting int: $e');
    }
  }

  static Future<int?> getInt(String key) async {
    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final value = await _secureStorage.read(key: key);
        return value != null ? int.parse(value) : null;
      } else {
        return _prefs?.getInt(key);
      }
    } catch (e) {
      developer.log('Error getting int: $e');
      return null;
    }
  }

  // Double operations
  static Future<void> setDouble(String key, double value) async {
    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        await _secureStorage.write(key: key, value: value.toString());
      } else {
        await _prefs?.setDouble(key, value);
        await _prefs?.commit();
      }
    } catch (e) {
      developer.log('Error setting double: $e');
    }
  }

  static Future<double?> getDouble(String key) async {
    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final value = await _secureStorage.read(key: key);
        return value != null ? double.parse(value) : null;
      } else {
        return _prefs?.getDouble(key);
      }
    } catch (e) {
      developer.log('Error getting double: $e');
      return null;
    }
  }

  // List operations
  static Future<void> setStringList(String key, List<String> value) async {
    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        await _secureStorage.write(key: key, value: value.join(','));
      } else {
        await _prefs?.setStringList(key, value);
        await _prefs?.commit();
      }
    } catch (e) {
      developer.log('Error setting string list: $e');
    }
  }

  static Future<List<String>?> getStringList(String key) async {
    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final value = await _secureStorage.read(key: key);
        return value?.split(',');
      } else {
        return _prefs?.getStringList(key);
      }
    } catch (e) {
      developer.log('Error getting string list: $e');
      return null;
    }
  }

  // Clear operations
  static Future<void> clear() async {
    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        await _secureStorage.deleteAll();
      } else {
        await _prefs?.clear();
        await _prefs?.commit();
      }
    } catch (e) {
      developer.log('Error clearing preferences: $e');
    }
  }

  static Future<void> remove(String key) async {
    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        await _secureStorage.delete(key: key);
      } else {
        await _prefs?.remove(key);
        await _prefs?.commit();
      }
    } catch (e) {
      developer.log('Error removing key: $e');
    }
  }
} 