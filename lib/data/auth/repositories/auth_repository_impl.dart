import '../../../domain/auth/entities/token.dart';
import '../../../domain/auth/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/token_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._local);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<AuthToken> login({
    required String username,
    required String password,
  }) async {
    final token = await _remote.login(username: username, password: password);
    await _local.saveToken(token);
    return token.toEntity();
  }

  @override
  Future<AuthToken?> getSavedToken() async {
    final token = await _local.getToken();
    return token?.toEntity();
  }

  @override
  Future<void> saveToken(AuthToken token) async {
    await _local.saveToken(TokenModel.fromEntity(token));
  }

  @override
  Future<void> logout() async {
    await _local.clear();
  }

  @override
  Future<AuthToken> refreshToken(String refreshToken) async {
    final token = await _remote.refresh(refreshToken);
    await _local.saveToken(token);
    return token.toEntity();
  }
}
