import 'dart:async';

import 'package:dio/dio.dart';

import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required AuthLocalDataSource localDataSource,
    required AuthRemoteDataSource remoteDataSource,
    required Dio dio,
  })  : _local = localDataSource,
        _remote = remoteDataSource,
        _dio = dio;

  final AuthLocalDataSource _local;
  final AuthRemoteDataSource _remote;
  final Dio _dio;

  Completer<void>? _refreshCompleter;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isAuthRequest(options.path)) {
      handler.next(options);
      return;
    }
    final token = await _local.getToken();
    if (token != null && token.access.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${token.access}';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401 || _isAuthRequest(err.requestOptions.path)) {
      handler.next(err);
      return;
    }

    final token = await _local.getToken();
    if (token?.refresh == null || token!.refresh.isEmpty) {
      handler.next(err);
      return;
    }

    try {
      await _refreshTokenIfNeeded(token.refresh);
      final retryOptions = err.requestOptions;
      final latest = await _local.getToken();
      if (latest != null && latest.access.isNotEmpty) {
        retryOptions.headers['Authorization'] = 'Bearer ${latest.access}';
      }
      final response = await _dio.fetch(retryOptions);
      handler.resolve(response);
    } catch (_) {
      handler.next(err);
    }
  }

  Future<void> _refreshTokenIfNeeded(String refreshToken) async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }
    _refreshCompleter = Completer<void>();
    try {
      final refreshed = await _remote.refresh(refreshToken);
      await _local.saveToken(refreshed);
      _refreshCompleter?.complete();
    } catch (error) {
      _refreshCompleter?.completeError(error);
      rethrow;
    } finally {
      _refreshCompleter = null;
    }
  }

  bool _isAuthRequest(String path) {
    return path.contains('auth/token/') || path.contains('auth/refresh/');
  }
}
