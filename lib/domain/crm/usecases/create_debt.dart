import '../entities/debt.dart';
import '../repositories/crm_repository.dart';

class CreateDebt {
  CreateDebt(this._repository);

  final CrmRepository _repository;

  Future<CrmDebt> call({
    required String fullName,
    required String amount,
    String? phone,
    String? note,
  }) {
    return _repository.createDebt(
      fullName: fullName,
      amount: amount,
      phone: phone,
      note: note,
    );
  }
}
