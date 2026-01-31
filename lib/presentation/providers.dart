import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/api_config.dart';
import '../core/config/env.dart';
import '../core/network/dio_client.dart';
import '../data/auth/datasources/auth_local_data_source.dart';
import '../data/auth/datasources/auth_remote_data_source.dart';
import '../data/auth/interceptors/auth_interceptor.dart';
import '../data/auth/repositories/auth_repository_impl.dart';
import '../data/authors/datasources/author_remote_data_source.dart';
import '../data/authors/repositories/author_repository_impl.dart';
import '../data/catalog/datasources/catalog_remote_data_source.dart';
import '../data/catalog/repositories/catalog_repository_impl.dart';
import '../data/crm/datasources/crm_remote_data_source.dart';
import '../data/crm/repositories/crm_repository_impl.dart';
import '../data/home/datasources/home_remote_data_source.dart';
import '../data/home/repositories/home_repository_impl.dart';
import '../domain/auth/repositories/auth_repository.dart';
import '../domain/auth/usecases/get_saved_token.dart';
import '../domain/auth/usecases/login.dart';
import '../domain/auth/usecases/logout.dart';
import '../domain/authors/repositories/author_repository.dart';
import '../domain/authors/usecases/get_authors.dart';
import '../domain/catalog/repositories/catalog_repository.dart';
import '../domain/catalog/usecases/get_books.dart';
import '../domain/catalog/usecases/get_categories.dart';
import '../domain/crm/repositories/crm_repository.dart';
import '../domain/crm/usecases/adjust_inventory.dart';
import '../domain/crm/usecases/create_debt.dart';
import '../domain/crm/usecases/create_expense.dart';
import '../domain/crm/usecases/create_pos_order.dart';
import '../domain/crm/usecases/get_books.dart';
import '../domain/crm/usecases/get_dashboard.dart';
import '../domain/crm/usecases/get_debts.dart';
import '../domain/crm/usecases/get_expenses.dart';
import '../domain/crm/usecases/get_orders.dart';
import '../domain/crm/usecases/get_report.dart';
import '../domain/crm/usecases/search.dart';
import '../domain/crm/usecases/update_debt_paid.dart';
import '../domain/home/repositories/home_repository.dart';
import '../domain/home/usecases/get_home.dart';
import 'controllers/auth_controller.dart';
import 'controllers/authors_controller.dart';
import 'controllers/base_url_controller.dart';
import 'controllers/books_controller.dart';
import 'controllers/categories_controller.dart';
import 'controllers/crm_books_controller.dart';
import 'controllers/crm_dashboard_controller.dart';
import 'controllers/crm_debts_controller.dart';
import 'controllers/crm_expenses_controller.dart';
import 'controllers/crm_orders_controller.dart';
import 'controllers/crm_pos_controller.dart';
import 'controllers/crm_report_controller.dart';
import 'controllers/crm_search_controller.dart';
import 'controllers/home_controller.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final apiConfigProvider = Provider<ApiConfig>((ref) {
  return ApiConfig(ref.read(secureStorageProvider));
});

final baseUrlControllerProvider =
    StateNotifierProvider<BaseUrlController, String>((ref) {
  return BaseUrlController(
    config: ref.read(apiConfigProvider),
    initial: Env.baseUrl,
  );
});

final authDioProvider = Provider<Dio>((ref) {
  final baseUrl = ref.watch(baseUrlControllerProvider);
  return DioClient(baseUrl: baseUrl).create();
});

final apiDioProvider = Provider<Dio>((ref) {
  final baseUrl = ref.watch(baseUrlControllerProvider);
  final dio = DioClient(baseUrl: baseUrl).create();
  dio.interceptors.add(
    AuthInterceptor(
      localDataSource: ref.read(authLocalDataSourceProvider),
      remoteDataSource: ref.read(authRemoteDataSourceProvider),
      dio: dio,
    ),
  );
  return dio;
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSource(ref.read(secureStorageProvider));
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.read(authDioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(authRemoteDataSourceProvider),
    ref.read(authLocalDataSourceProvider),
  );
});

final loginUseCaseProvider = Provider<Login>((ref) {
  return Login(ref.read(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<Logout>((ref) {
  return Logout(ref.read(authRepositoryProvider));
});

final getSavedTokenUseCaseProvider = Provider<GetSavedToken>((ref) {
  return GetSavedToken(ref.read(authRepositoryProvider));
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    login: ref.read(loginUseCaseProvider),
    logout: ref.read(logoutUseCaseProvider),
    getSavedToken: ref.read(getSavedTokenUseCaseProvider),
  )..checkAuth();
});

final authorRemoteDataSourceProvider = Provider<AuthorRemoteDataSource>((ref) {
  return AuthorRemoteDataSource(ref.read(apiDioProvider));
});

final authorRepositoryProvider = Provider<AuthorRepository>((ref) {
  return AuthorRepositoryImpl(ref.read(authorRemoteDataSourceProvider));
});

final getAuthorsUseCaseProvider = Provider<GetAuthors>((ref) {
  return GetAuthors(ref.read(authorRepositoryProvider));
});

final authorsControllerProvider =
    StateNotifierProvider<AuthorsController, AuthorsState>((ref) {
  return AuthorsController(getAuthors: ref.read(getAuthorsUseCaseProvider));
});

final catalogRemoteDataSourceProvider = Provider<CatalogRemoteDataSource>((ref) {
  return CatalogRemoteDataSource(ref.read(apiDioProvider));
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepositoryImpl(ref.read(catalogRemoteDataSourceProvider));
});

final getCategoriesUseCaseProvider = Provider<GetCategories>((ref) {
  return GetCategories(ref.read(catalogRepositoryProvider));
});

final getBooksUseCaseProvider = Provider<GetBooks>((ref) {
  return GetBooks(ref.read(catalogRepositoryProvider));
});

final categoriesControllerProvider =
    StateNotifierProvider<CategoriesController, CategoriesState>((ref) {
  return CategoriesController(getCategories: ref.read(getCategoriesUseCaseProvider));
});

final booksControllerProvider = StateNotifierProvider.family<
    BooksController,
    BooksState,
    BooksQuery>((ref, query) {
  return BooksController(
    getBooks: ref.read(getBooksUseCaseProvider),
    query: query,
  );
});

final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  return HomeRemoteDataSource(ref.read(apiDioProvider));
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl(ref.read(homeRemoteDataSourceProvider));
});

final getHomeUseCaseProvider = Provider<GetHome>((ref) {
  return GetHome(ref.read(homeRepositoryProvider));
});

final homeControllerProvider =
    StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController(getHome: ref.read(getHomeUseCaseProvider));
});

final crmRemoteDataSourceProvider = Provider<CrmRemoteDataSource>((ref) {
  return CrmRemoteDataSource(ref.read(apiDioProvider));
});

final crmRepositoryProvider = Provider<CrmRepository>((ref) {
  return CrmRepositoryImpl(ref.read(crmRemoteDataSourceProvider));
});

final getDashboardUseCaseProvider = Provider<GetDashboard>((ref) {
  return GetDashboard(ref.read(crmRepositoryProvider));
});

final getOrdersUseCaseProvider = Provider<GetOrders>((ref) {
  return GetOrders(ref.read(crmRepositoryProvider));
});

final getDebtsUseCaseProvider = Provider<GetDebts>((ref) {
  return GetDebts(ref.read(crmRepositoryProvider));
});

final createDebtUseCaseProvider = Provider<CreateDebt>((ref) {
  return CreateDebt(ref.read(crmRepositoryProvider));
});

final updateDebtPaidUseCaseProvider = Provider<UpdateDebtPaid>((ref) {
  return UpdateDebtPaid(ref.read(crmRepositoryProvider));
});

final getExpensesUseCaseProvider = Provider<GetExpenses>((ref) {
  return GetExpenses(ref.read(crmRepositoryProvider));
});

final createExpenseUseCaseProvider = Provider<CreateExpense>((ref) {
  return CreateExpense(ref.read(crmRepositoryProvider));
});

final getCrmBooksUseCaseProvider = Provider<GetCrmBooks>((ref) {
  return GetCrmBooks(ref.read(crmRepositoryProvider));
});

final adjustInventoryUseCaseProvider = Provider<AdjustInventory>((ref) {
  return AdjustInventory(ref.read(crmRepositoryProvider));
});

final getReportUseCaseProvider = Provider<GetCrmReport>((ref) {
  return GetCrmReport(ref.read(crmRepositoryProvider));
});

final createPosOrderUseCaseProvider = Provider<CreatePosOrder>((ref) {
  return CreatePosOrder(ref.read(crmRepositoryProvider));
});

final crmSearchUseCaseProvider = Provider<CrmSearch>((ref) {
  return CrmSearch(ref.read(crmRepositoryProvider));
});

final crmDashboardControllerProvider =
    StateNotifierProvider<CrmDashboardController, CrmDashboardState>((ref) {
  return CrmDashboardController(getDashboard: ref.read(getDashboardUseCaseProvider));
});

final crmOrdersControllerProvider = StateNotifierProvider.family<
    CrmOrdersController,
    CrmOrdersState,
    CrmOrdersQuery>((ref, query) {
  return CrmOrdersController(
    getOrders: ref.read(getOrdersUseCaseProvider),
    query: query,
  );
});

final crmDebtsControllerProvider =
    StateNotifierProvider<CrmDebtsController, CrmDebtsState>((ref) {
  return CrmDebtsController(
    getDebts: ref.read(getDebtsUseCaseProvider),
    createDebt: ref.read(createDebtUseCaseProvider),
    updateDebtPaid: ref.read(updateDebtPaidUseCaseProvider),
  );
});

final crmExpensesControllerProvider =
    StateNotifierProvider<CrmExpensesController, CrmExpensesState>((ref) {
  return CrmExpensesController(
    getExpenses: ref.read(getExpensesUseCaseProvider),
    createExpense: ref.read(createExpenseUseCaseProvider),
  );
});

final crmBooksControllerProvider = StateNotifierProvider.family<
    CrmBooksController,
    CrmBooksState,
    String?>((ref, query) {
  return CrmBooksController(
    getBooks: ref.read(getCrmBooksUseCaseProvider),
    query: query,
  );
});

final crmReportControllerProvider =
    StateNotifierProvider<CrmReportController, CrmReportState>((ref) {
  return CrmReportController(getReport: ref.read(getReportUseCaseProvider));
});

final crmPosControllerProvider =
    StateNotifierProvider<CrmPosController, CrmPosState>((ref) {
  return CrmPosController(createPosOrder: ref.read(createPosOrderUseCaseProvider));
});

final crmSearchControllerProvider =
    StateNotifierProvider<CrmSearchController, CrmSearchState>((ref) {
  return CrmSearchController(search: ref.read(crmSearchUseCaseProvider));
});
