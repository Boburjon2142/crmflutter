import '../entities/token.dart';

abstract class AuthRepository {
  Future<AuthToken> login({
    required String username,
    required String password,
  });

  Future<AuthToken?> getSavedToken();

  Future<void> saveToken(AuthToken token);

  Future<void> logout();

  Future<AuthToken> refreshToken(String refreshToken);
}
