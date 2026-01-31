import '../entities/token.dart';
import '../repositories/auth_repository.dart';

class GetSavedToken {
  GetSavedToken(this._repository);

  final AuthRepository _repository;

  Future<AuthToken?> call() => _repository.getSavedToken();
}
