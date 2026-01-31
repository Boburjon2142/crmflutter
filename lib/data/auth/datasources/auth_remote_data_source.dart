import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../models/token_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<TokenModel> login({
    required String username,
    required String password,
  }) async {
    ApiException? lastApiError;
    DioException? lastDioError;
    for (final field in const ['username', 'email', 'login']) {
      try {
        return await _loginWithField(
          field: field,
          value: username,
          password: password,
        );
      } on ApiException catch (error) {
        lastApiError = error;
        final status = error.statusCode;
        if (status == 400 || status == 401 || status == 403) {
          continue;
        }
        rethrow;
      } on DioException catch (error) {
        lastDioError = error;
        final status = error.response?.statusCode;
        if (status != null && status >= 500) {
          rethrow;
        }
      }
    }
    if (lastApiError != null) {
      throw lastApiError;
    }
    final message = _extractMessage(lastDioError);
    throw ApiException(
      message,
      statusCode: lastDioError?.response?.statusCode,
    );
  }

  Future<TokenModel> _loginWithField({
    required String field,
    required String value,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'auth/token/',
        data: {
          field: value,
          'password': password,
        },
        options: Options(
          followRedirects: true,
          validateStatus: (status) => status != null && status < 400,
        ),
      );
      if (response.statusCode != 200) {
        throw ApiException(
          _extractMessageFromResponse(response),
          statusCode: response.statusCode,
        );
      }
      return TokenModel.fromJson(response.data ?? {});
    } on DioException catch (error) {
      rethrow;
    }
  }

  Future<TokenModel> refresh(String refreshToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'auth/refresh/',
        data: {'refresh': refreshToken},
        options: Options(
          followRedirects: true,
          validateStatus: (status) => status != null && status < 400,
        ),
      );
      if (response.statusCode != 200) {
        throw ApiException(
          _redirectMessage(response),
          statusCode: response.statusCode,
        );
      }
      final data = response.data ?? {};
      if (data['refresh'] == null) {
        data['refresh'] = refreshToken;
      }
      return TokenModel.fromJson(data);
    } on DioException catch (error) {
      final message = _extractMessage(error);
      throw ApiException(
        message,
        statusCode: error.response?.statusCode,
      );
    }
  }
}

String _extractMessage(DioException? error) {
  if (error == null) {
    return 'Kirish muvaffaqiyatsiz';
  }
  final data = error.response?.data;
  if (data is String && data.trim().isNotEmpty) {
    return data;
  }
  if (data is Map<String, dynamic>) {
    final detail = data['detail'];
    if (detail is String && detail.trim().isNotEmpty) {
      return detail;
    }
    final errors = data['non_field_errors'];
    if (errors is List && errors.isNotEmpty) {
      return errors.first.toString();
    }
  }
  final status = error.response?.statusCode;
  if (status != null) {
    return 'Kirish muvaffaqiyatsiz (HTTP $status)';
  }
  final message = error.message;
  if (message != null && message.trim().isNotEmpty) {
    return 'Network error: $message';
  }
  return error.response?.statusMessage ?? 'Kirish muvaffaqiyatsiz';
}

String _extractMessageFromResponse(Response response) {
  final data = response.data;
  if (data is String && data.trim().isNotEmpty) {
    return data;
  }
  if (data is Map<String, dynamic>) {
    final detail = data['detail'];
    if (detail is String && detail.trim().isNotEmpty) {
      return detail;
    }
    final errors = data['non_field_errors'];
    if (errors is List && errors.isNotEmpty) {
      return errors.first.toString();
    }
    for (final key in ['username', 'email', 'login', 'password']) {
      final fieldErrors = data[key];
      if (fieldErrors is List && fieldErrors.isNotEmpty) {
        return fieldErrors.first.toString();
      }
    }
  }
  return 'Kirish muvaffaqiyatsiz (HTTP ${response.statusCode})';
}

bool _shouldRetryWithField(DioException error, String field) {
  final data = error.response?.data;
  if (data is Map<String, dynamic> && data.containsKey(field)) {
    return true;
  }
  if (data is Map<String, dynamic>) {
    final detail = data['detail'];
    if (detail is String && detail.toLowerCase().contains(field)) {
      return true;
    }
  }
  return false;
}

String _redirectMessage(Response response) {
  final location = response.headers.value('location');
  if (location != null && location.trim().isNotEmpty) {
    return 'Unexpected redirect to $location';
  }
  return 'Kirish muvaffaqiyatsiz (HTTP ${response.statusCode})';
}
