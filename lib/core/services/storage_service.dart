import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveKey(String provider, String key) async {
    await _storage.write(key: 'api_key_$provider', value: key);
  }

  static Future<String?> getKey(String provider) async {
    return await _storage.read(key: 'api_key_$provider');
  }

  static Future<void> deleteKey(String provider) async {
    await _storage.delete(key: 'api_key_$provider');
  }
}
