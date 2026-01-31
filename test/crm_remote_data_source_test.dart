import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bilim_app/data/crm/datasources/crm_remote_data_source.dart';

void main() {
  test('getBooks paginates and aggregates all pages', () async {
    final adapter = _FakeAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.com/api/'));
    dio.httpClientAdapter = adapter;

    final dataSource = CrmRemoteDataSource(dio);
    final items = await dataSource.getBooks();

    expect(items.length, 3);
    expect(adapter.requests.length, 2);
    expect(adapter.requests.first.queryParameters['page'], 1);
    expect(adapter.requests.last.queryParameters['page'], 2);
  });

  test('getBooks passes query parameter', () async {
    final adapter = _FakeAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.com/api/'));
    dio.httpClientAdapter = adapter;

    final dataSource = CrmRemoteDataSource(dio);
    await dataSource.getBooks(query: 'al');

    expect(adapter.requests.isNotEmpty, true);
    expect(adapter.requests.first.queryParameters['q'], 'al');
  });
}

class _FakeAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final page = options.queryParameters['page'] ?? 1;
    final payload = page == 1
        ? {
            'count': 3,
            'next': 'https://example.com/api/books/?page=2',
            'previous': null,
            'results': [
              _bookJson(1, 'Birinchi'),
              _bookJson(2, 'Ikkinchi'),
            ],
          }
        : {
            'count': 3,
            'next': null,
            'previous': 'https://example.com/api/books/?page=1',
            'results': [
              _bookJson(3, 'Uchinchi'),
            ],
          };

    final bytes = utf8.encode(jsonEncode(payload));
    return ResponseBody.fromBytes(
      bytes,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

Map<String, dynamic> _bookJson(int id, String title) {
  return {
    'id': id,
    'title': title,
    'slug': 'slug-$id',
    'category': null,
    'author': null,
    'purchase_price': 10000,
    'sale_price': 15000,
    'description': '',
    'book_format': null,
    'pages': null,
    'views': 0,
    'barcode': null,
    'stock_quantity': 0,
    'cover_image_url': null,
    'created_at': null,
  };
}
