import '../entities/debt.dart';
import '../repositories/crm_repository.dart';

class UpdateDebtNote {
  UpdateDebtNote(this._repository);

  final CrmRepository _repository;

  Future<CrmDebt> call({
    required int id,
    required String note,
  }) {
    return _repository.updateDebtNote(id: id, note: note);
  }
}
