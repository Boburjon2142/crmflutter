import '../../../core/network/paginated_response.dart';
import '../../../domain/catalog/entities/book.dart';
import '../../../domain/catalog/entities/category.dart';
import '../../../domain/catalog/repositories/catalog_repository.dart';
import '../datasources/catalog_remote_data_source.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._remote);

  final CatalogRemoteDataSource _remote;

  @override
  Future<List<Category>> getCategories() async {
    final response = await _remote.getCategories();
    return response.map((item) => item.toEntity()).toList();
  }

  @override
  Future<PaginatedResponse<Book>> getBooks({
    int page = 1,
    String? query,
    int? categoryId,
    String? categorySlug,
    String? sort,
    int? authorId,
  }) async {
    final response = await _remote.getBooks(
      page: page,
      query: query,
      categoryId: categoryId,
      categorySlug: categorySlug,
      sort: sort,
      authorId: authorId,
    );
    return PaginatedResponse(
      count: response.count,
      next: response.next,
      previous: response.previous,
      results: response.results.map((item) => item.toEntity()).toList(),
    );
  }
}
