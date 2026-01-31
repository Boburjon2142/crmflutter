import '../entities/expense.dart';
import '../repositories/crm_repository.dart';

class CreateExpense {
  CreateExpense(this._repository);

  final CrmRepository _repository;

  Future<CrmExpense> call({
    required String title,
    required String amount,
    String? spentOn,
    String? note,
  }) {
    return _repository.createExpense(
      title: title,
      amount: amount,
      spentOn: spentOn,
      note: note,
    );
  }
}
