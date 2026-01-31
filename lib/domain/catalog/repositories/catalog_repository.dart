import '../../../core/network/paginated_response.dart';
import '../entities/book.dart';
import '../entities/category.dart';

abstract class CatalogRepository {
  Future<List<Category>> getCategories();

  Future<PaginatedResponse<Book>> getBooks({
    int page = 1,
    String? query,
    int? categoryId,
    String? categorySlug,
    String? sort,
    int? authorId,
  });
}
