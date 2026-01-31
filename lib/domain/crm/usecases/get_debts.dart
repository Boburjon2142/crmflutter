import '../entities/debt.dart';
import '../repositories/crm_repository.dart';

class GetDebts {
  GetDebts(this._repository);

  final CrmRepository _repository;

  Future<List<CrmDebt>> call() => _repository.getDebts();
}
