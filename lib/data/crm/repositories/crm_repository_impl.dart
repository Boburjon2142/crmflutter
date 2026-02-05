import '../../../core/network/paginated_response.dart';
import '../../../domain/catalog/entities/book.dart';
import '../../../domain/crm/entities/dashboard.dart';
import '../../../domain/crm/entities/debt.dart';
import '../../../domain/crm/entities/expense.dart';
import '../../../domain/crm/entities/order.dart';
import '../../../domain/crm/entities/search.dart';
import '../../../domain/crm/repositories/crm_repository.dart';
import '../datasources/crm_remote_data_source.dart';

class CrmRepositoryImpl implements CrmRepository {
  CrmRepositoryImpl(this._remote);

  final CrmRemoteDataSource _remote;

  @override
  Future<CrmDashboard> getDashboard() async {
    final response = await _remote.getDashboard();
    return response.toEntity();
  }

  @override
  Future<PaginatedResponse<CrmOrder>> getOrders({
    int page = 1,
    String? status,
  }) async {
    final response = await _remote.getOrders(page: page, status: status);
    return PaginatedResponse(
      count: response.count,
      next: response.next,
      previous: response.previous,
      results: response.results.map((item) => item.toEntity()).toList(),
    );
  }

  @override
  Future<List<Book>> getBooks({String? query}) async {
    final response = await _remote.getBooks(query: query);
    return response.map((item) => item.toEntity()).toList();
  }

  @override
  Future<void> adjustInventory({
    required int bookId,
    required int delta,
    String? note,
  }) {
    return _remote.adjustInventory(bookId: bookId, delta: delta, note: note);
  }

  @override
  Future<List<CrmDebt>> getDebts() async {
    final response = await _remote.getDebts();
    return response.map((item) => item.toEntity()).toList();
  }

  @override
  Future<CrmDebt> createDebt({
    required String fullName,
    required String amount,
    String? phone,
    String? note,
  }) async {
    final response = await _remote.createDebt(
      fullName: fullName,
      amount: amount,
      phone: phone,
      note: note,
    );
    return response.toEntity();
  }

  @override
  Future<CrmDebt> updateDebtPaid({
    required int id,
    required String paidAmount,
    required bool isPaid,
  }) async {
    final response = await _remote.updateDebtPaid(
      id: id,
      paidAmount: paidAmount,
      isPaid: isPaid,
    );
    return response.toEntity();
  }

  @override
  Future<CrmDebt> updateDebtNote({
    required int id,
    required String note,
  }) async {
    final response = await _remote.updateDebtNote(
      id: id,
      note: note,
    );
    return response.toEntity();
  }

  @override
  Future<List<CrmExpense>> getExpenses() async {
    final response = await _remote.getExpenses();
    return response.map((item) => item.toEntity()).toList();
  }

  @override
  Future<CrmExpense> createExpense({
    required String title,
    required String amount,
    String? spentOn,
    String? note,
  }) async {
    final response = await _remote.createExpense(
      title: title,
      amount: amount,
      spentOn: spentOn,
      note: note,
    );
    return response.toEntity();
  }

  @override
  Future<Map<String, dynamic>> getReport({
    String? start,
    String? end,
    String? startTime,
    String? endTime,
  }) {
    return _remote.getReport(
      start: start,
      end: end,
      startTime: startTime,
      endTime: endTime,
    );
  }

  @override
  Future<Map<String, dynamic>> createPosOrder({
    required List<Map<String, dynamic>> items,
    String? fullName,
    String? phone,
    String? paymentType,
    String? discountAmount,
  }) {
    return _remote.createPosOrder(
      items: items,
      fullName: fullName,
      phone: phone,
      paymentType: paymentType,
      discountAmount: discountAmount,
    );
  }

  @override
  Future<CrmSearchResult> search(String query) async {
    final response = await _remote.search(query);
    return response.toEntity();
  }
}
