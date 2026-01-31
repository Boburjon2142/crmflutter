import '../../../core/network/paginated_response.dart';
import '../entities/author.dart';
import '../repositories/author_repository.dart';

class GetAuthors {
  GetAuthors(this._repository);

  final AuthorRepository _repository;

  Future<PaginatedResponse<Author>> call({int page = 1}) {
    return _repository.getAuthors(page: page);
  }
}
