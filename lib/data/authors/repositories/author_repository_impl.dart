import '../../../core/network/paginated_response.dart';
import '../../../domain/authors/entities/author.dart';
import '../../../domain/authors/repositories/author_repository.dart';
import '../datasources/author_remote_data_source.dart';

class AuthorRepositoryImpl implements AuthorRepository {
  AuthorRepositoryImpl(this._remote);

  final AuthorRemoteDataSource _remote;

  @override
  Future<PaginatedResponse<Author>> getAuthors({int page = 1}) async {
    final response = await _remote.getAuthors(page: page);
    return PaginatedResponse(
      count: response.count,
      next: response.next,
      previous: response.previous,
      results: response.results.map((item) => item.toEntity()).toList(),
    );
  }
}
