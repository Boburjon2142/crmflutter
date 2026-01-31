import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'env.dart';

class ApiConfig {
  ApiConfig(this._storage);

  final FlutterSecureStorage _storage;

  static const _key = 'api_base_url';

  Future<String> loadBaseUrl() async {
    final stored = await _storage.read(key: _key);
    if (stored == null || stored.trim().isEmpty) {
      return Env.baseUrl;
    }
    return normalize(stored);
  }

  Future<void> saveBaseUrl(String value) async {
    await _storage.write(key: _key, value: normalize(value));
  }

  String normalize(String value) {
    var trimmed = value.trim();
    if (trimmed.isEmpty) {
      return Env.baseUrl;
    }
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      trimmed = 'https://$trimmed';
    }
    if (!trimmed.endsWith('/')) {
      trimmed = '$trimmed/';
    }
    return trimmed;
  }
}
