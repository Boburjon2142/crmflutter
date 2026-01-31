import '../../../core/network/paginated_response.dart';
import '../entities/order.dart';
import '../repositories/crm_repository.dart';

class GetOrders {
  GetOrders(this._repository);

  final CrmRepository _repository;

  Future<PaginatedResponse<CrmOrder>> call({
    int page = 1,
    String? status,
  }) {
    return _repository.getOrders(page: page, status: status);
  }
}
