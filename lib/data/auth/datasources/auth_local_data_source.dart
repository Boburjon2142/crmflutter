import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/token_model.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  Future<void> saveToken(TokenModel token) async {
    await _storage.write(key: _accessKey, value: token.access);
    await _storage.write(key: _refreshKey, value: token.refresh);
  }

  Future<TokenModel?> getToken() async {
    final access = await _storage.read(key: _accessKey);
    final refresh = await _storage.read(key: _refreshKey);
    if (access == null || refresh == null) {
      return null;
    }
    return TokenModel(access: access, refresh: refresh);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
