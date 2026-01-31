import '../../../core/network/paginated_response.dart';
import '../entities/dashboard.dart';
import '../entities/debt.dart';
import '../entities/order.dart';
import '../entities/expense.dart';
import '../../catalog/entities/book.dart';
import '../entities/search.dart';

abstract class CrmRepository {
  Future<CrmDashboard> getDashboard();

  Future<PaginatedResponse<CrmOrder>> getOrders({
    int page = 1,
    String? status,
  });

  Future<List<Book>> getBooks({String? query});

  Future<void> adjustInventory({
    required int bookId,
    required int delta,
    String? note,
  });

  Future<List<CrmDebt>> getDebts();

  Future<CrmDebt> createDebt({
    required String fullName,
    required String amount,
    String? phone,
    String? note,
  });

  Future<List<CrmExpense>> getExpenses();

  Future<CrmExpense> createExpense({
    required String title,
    required String amount,
    String? spentOn,
    String? note,
  });

  Future<Map<String, dynamic>> getReport({
    String? start,
    String? end,
    String? startTime,
    String? endTime,
  });

  Future<Map<String, dynamic>> createPosOrder({
    required List<Map<String, dynamic>> items,
    String? fullName,
    String? phone,
    String? paymentType,
    String? discountAmount,
  });

  Future<CrmSearchResult> search(String query);
}
