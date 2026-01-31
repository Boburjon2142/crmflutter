import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../models/home_model.dart';

class HomeRemoteDataSource {
  HomeRemoteDataSource(this._dio);

  final Dio _dio;

  Future<HomeModel> getHome() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('home/');
      return HomeModel.fromJson(response.data ?? {});
    } on DioException catch (error) {
      throw ApiException(
        _extractMessage(error),
        statusCode: error.response?.statusCode,
      );
    }
  }
}

String _extractMessage(DioException error) {
  final data = error.response?.data;
  if (data is String && data.trim().isNotEmpty) {
    return data;
  }
  if (data is Map<String, dynamic>) {
    final detail = data['detail'];
    if (detail is String && detail.trim().isNotEmpty) {
      return detail;
    }
  }
  final status = error.response?.statusCode;
  if (status != null) {
    return 'Failed to load home feed (HTTP $status)';
  }
  return error.message ?? 'Failed to load home feed';
}
