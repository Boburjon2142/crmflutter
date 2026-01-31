import '../../../core/network/paginated_response.dart';
import '../entities/author.dart';

abstract class AuthorRepository {
  Future<PaginatedResponse<Author>> getAuthors({int page = 1});
}
