import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/paginated_response.dart';
import '../models/book_model.dart';
import '../models/category_model.dart';

class CatalogRemoteDataSource {
  CatalogRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get<List<dynamic>>('categories/');
      final data = response.data ?? [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(CategoryModel.fromJson)
          .toList();
    } on DioException catch (error) {
      throw ApiException(
        error.response?.statusMessage ?? 'Failed to load categories',
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<PaginatedResponse<BookModel>> getBooks({
    int page = 1,
    String? query,
    int? categoryId,
    String? categorySlug,
    String? sort,
    int? authorId,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'books/',
        queryParameters: {
          'page': page,
          if (query != null && query.isNotEmpty) 'q': query,
          if (categoryId != null) 'category_id': categoryId,
          if (categorySlug != null && categorySlug.isNotEmpty)
            'category_slug': categorySlug,
          if (sort != null && sort.isNotEmpty) 'sort': sort,
          if (authorId != null) 'author_id': authorId,
        },
      );
      return PaginatedResponse.fromJson(
        response.data ?? {},
        (json) => BookModel.fromJson(json),
      );
    } on DioException catch (error) {
      throw ApiException(
        error.response?.statusMessage ?? 'Failed to load books',
        statusCode: error.response?.statusCode,
      );
    }
  }
}
