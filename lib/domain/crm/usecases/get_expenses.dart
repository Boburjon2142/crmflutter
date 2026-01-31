import '../entities/expense.dart';
import '../repositories/crm_repository.dart';

class GetExpenses {
  GetExpenses(this._repository);

  final CrmRepository _repository;

  Future<List<CrmExpense>> call() => _repository.getExpenses();
}
