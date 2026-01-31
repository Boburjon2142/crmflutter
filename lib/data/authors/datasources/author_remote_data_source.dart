import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/paginated_response.dart';
import '../models/author_model.dart';

class AuthorRemoteDataSource {
  AuthorRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedResponse<AuthorModel>> getAuthors({int page = 1}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'authors/',
        queryParameters: {'page': page},
      );
      return PaginatedResponse.fromJson(
        response.data ?? {},
        (json) => AuthorModel.fromJson(json),
      );
    } on DioException catch (error) {
      throw ApiException(
        error.response?.statusMessage ?? 'Failed to load authors',
        statusCode: error.response?.statusCode,
      );
    }
  }
}
