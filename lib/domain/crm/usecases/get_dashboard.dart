import '../entities/dashboard.dart';
import '../repositories/crm_repository.dart';

class GetDashboard {
  GetDashboard(this._repository);

  final CrmRepository _repository;

  Future<CrmDashboard> call() => _repository.getDashboard();
}
