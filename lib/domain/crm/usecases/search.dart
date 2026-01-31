import '../entities/search.dart';
import '../repositories/crm_repository.dart';

class CrmSearch {
  CrmSearch(this._repository);

  final CrmRepository _repository;

  Future<CrmSearchResult> call(String query) => _repository.search(query);
}
