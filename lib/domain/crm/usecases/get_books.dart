import '../../catalog/entities/book.dart';
import '../repositories/crm_repository.dart';

class GetCrmBooks {
  GetCrmBooks(this._repository);

  final CrmRepository _repository;

  Future<List<Book>> call({String? query}) {
    return _repository.getBooks(query: query);
  }
}
