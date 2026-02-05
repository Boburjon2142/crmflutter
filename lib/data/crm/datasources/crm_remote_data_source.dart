import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/paginated_response.dart';
import '../../catalog/models/book_model.dart';
import '../models/dashboard_model.dart';
import '../models/debt_model.dart';
import '../models/expense_model.dart';
import '../models/order_model.dart';
import '../models/search_model.dart';

class CrmRemoteDataSource {
  CrmRemoteDataSource(this._dio);

  final Dio _dio;

  Future<CrmDashboardModel> getDashboard() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('crm/dashboard/');
      return CrmDashboardModel.fromJson(response.data ?? {});
    } on DioException catch (error) {
      throw ApiException(
        error.response?.statusMessage ?? 'Failed to load dashboard',
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<PaginatedResponse<OrderModel>> getOrders({
    int page = 1,
    String? status,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'orders/',
        queryParameters: {
          'page': page,
          if (status != null && status.isNotEmpty) 'status': status,
        },
      );
      return PaginatedResponse.fromJson(
        response.data ?? {},
        (json) => OrderModel.fromJson(json),
      );
    } on DioException catch (error) {
      throw ApiException(
        error.response?.statusMessage ?? 'Failed to load orders',
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<List<DebtModel>> getDebts() async {
    try {
      final response = await _dio.get<List<dynamic>>('crm/debts/');
      final data = response.data ?? [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(DebtModel.fromJson)
          .toList();
    } on DioException catch (error) {
      throw ApiException(
        error.response?.statusMessage ?? 'Failed to load debts',
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<DebtModel> createDebt({
    required String fullName,
    required String amount,
    String? phone,
    String? note,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'crm/debts/',
        data: {
          'full_name': fullName,
          'amount': amount,
          'phone': phone ?? '',
          'note': note ?? '',
        },
      );
      return DebtModel.fromJson(response.data ?? {});
    } on DioException catch (error) {
      throw ApiException(
        error.response?.statusMessage ?? 'Failed to create debt',
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<DebtModel> updateDebtPaid({
    required int id,
    required String paidAmount,
    required bool isPaid,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'crm/debts/pay/',
        data: {
          'debt_id': id,
          'paid_amount': paidAmount,
          'is_paid': isPaid ? '1' : '0',
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          validateStatus: (status) => status != null && status < 400,
        ),
      );
      return DebtModel.fromJson(response.data ?? {});
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      throw ApiException(
        error.response?.statusMessage ?? 'Failed to update debt',
        statusCode: status,
      );
    }
  }

  Future<DebtModel> updateDebtNote({
    required int id,
    required String note,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'crm/debts/note/',
        data: {
          'debt_id': id,
          'note': note,
        },
      );
      return DebtModel.fromJson(response.data ?? {});
    } on DioException catch (error) {
      throw ApiException(
        error.response?.statusMessage ?? 'Failed to update debt note',
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<List<ExpenseModel>> getExpenses() async {
    try {
      final response = await _dio.get<List<dynamic>>('crm/expenses/');
      final data = response.data ?? [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(ExpenseModel.fromJson)
          .toList();
    } on DioException catch (error) {
      throw ApiException(
        error.response?.statusMessage ?? 'Failed to load expenses',
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<ExpenseModel> createExpense({
    required String title,
    required String amount,
    String? spentOn,
    String? note,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'crm/expenses/',
        data: {
          'title': title,
          'amount': amount,
          'spent_on': spentOn ?? '',
          'note': note ?? '',
        },
      );
      return ExpenseModel.fromJson(response.data ?? {});
    } on DioException catch (error) {
      throw ApiException(
        error.response?.statusMessage ?? 'Failed to create expense',
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<List<BookModel>> getBooks({
    String? query,
  }) async {
    try {
      final items = <BookModel>[];
      var page = 1;
      while (true) {
        final response = await _dio.get<dynamic>(
          'books/',
          queryParameters: {
            'page': page,
            if (query != null && query.isNotEmpty) 'q': query,
          },
        );
        final raw = response.data;
        if (raw is List) {
          items.addAll(
            raw
                .whereType<Map<String, dynamic>>()
                .map(BookModel.fromJson),
          );
          break;
        }
        if (raw is Map<String, dynamic>) {
          final results = raw['results'];
          final list = results is List ? results : const [];
          items.addAll(
            list
                .whereType<Map<String, dynamic>>()
                .map(BookModel.fromJson),
          );
          final next = raw['next'] as String?;
          if (next == null || list.isEmpty) {
            break;
          }
          page += 1;
          continue;
        }
        break;
      }
      return items;
    } on DioException catch (error) {
      throw ApiException(
        error.response?.statusMessage ?? 'Failed to load books',
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<void> adjustInventory({
    required int bookId,
    required int delta,
    String? note,
  }) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        'crm/inventory/adjust/',
        data: {
          'book_id': bookId,
          'delta': delta,
          'note': note ?? '',
        },
      );
    } on DioException catch (error) {
      throw ApiException(
        error.response?.statusMessage ?? 'Failed to adjust inventory',
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> getReport({
    String? start,
    String? end,
    String? startTime,
    String? endTime,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'crm/report/',
        queryParameters: {
          if (start != null) 'start': start,
          if (end != null) 'end': end,
          if (startTime != null) 'start_time': startTime,
          if (endTime != null) 'end_time': endTime,
        },
      );
      return response.data ?? {};
    } on DioException catch (error) {
      throw ApiException(
        error.response?.statusMessage ?? 'Failed to load report',
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> createPosOrder({
    required List<Map<String, dynamic>> items,
    String? fullName,
    String? phone,
    String? paymentType,
    String? discountAmount,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'crm/pos/checkout/',
        data: {
          'items': items,
          'full_name': fullName,
          'phone': phone,
          'payment_type': paymentType,
          'discount_amount': discountAmount,
        },
      );
      return response.data ?? {};
    } on DioException catch (error) {
      throw ApiException(
        error.response?.statusMessage ?? 'POS buyurtma yaratib bo\'lmadi',
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<CrmSearchResultModel> search(String query) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'crm/search/',
        queryParameters: {'q': query},
      );
      return CrmSearchResultModel.fromJson(response.data ?? {});
    } on DioException catch (error) {
      throw ApiException(
        error.response?.statusMessage ?? 'Failed to search',
        statusCode: error.response?.statusCode,
      );
    }
  }
}
