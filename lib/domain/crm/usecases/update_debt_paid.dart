import '../entities/debt.dart';
import '../repositories/crm_repository.dart';

class UpdateDebtPaid {
  UpdateDebtPaid(this._repository);

  final CrmRepository _repository;

  Future<CrmDebt> call({
    required int id,
    required String paidAmount,
    required bool isPaid,
  }) {
    return _repository.updateDebtPaid(
      id: id,
      paidAmount: paidAmount,
      isPaid: isPaid,
    );
  }
}
