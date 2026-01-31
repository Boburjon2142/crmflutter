import '../entities/token.dart';
import '../repositories/auth_repository.dart';

class Login {
  Login(this._repository);

  final AuthRepository _repository;

  Future<AuthToken> call({
    required String username,
    required String password,
  }) {
    return _repository.login(username: username, password: password);
  }
}
