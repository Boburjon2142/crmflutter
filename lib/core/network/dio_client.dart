import 'package:dio/dio.dart';

class DioClient {
  DioClient({required this.baseUrl});

  final String baseUrl;

  Dio create({List<Interceptor> interceptors = const []}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.addAll(interceptors);
    return dio;
  }
}
