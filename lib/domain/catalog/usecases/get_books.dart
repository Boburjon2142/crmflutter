import '../../../core/network/paginated_response.dart';
import '../entities/book.dart';
import '../repositories/catalog_repository.dart';

class GetBooks {
  GetBooks(this._repository);

  final CatalogRepository _repository;

  Future<PaginatedResponse<Book>> call({
    int page = 1,
    String? query,
    int? categoryId,
    String? categorySlug,
    String? sort,
    int? authorId,
  }) {
    return _repository.getBooks(
      page: page,
      query: query,
      categoryId: categoryId,
      categorySlug: categorySlug,
      sort: sort,
      authorId: authorId,
    );
  }
}
