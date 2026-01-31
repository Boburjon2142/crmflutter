class ApiEndpoints {
  static const token = 'token/';
  static const jwtToken = 'auth/token/';
  static const jwtRefresh = 'auth/refresh/';

  static const home = 'home/';
  static const cacheDemo = 'cache-demo/';
  static const authors = 'authors/';
  static const categories = 'categories/';
  static const books = 'books/';
  static const orders = 'orders/';
  static const customers = 'customers/';
  static const couriers = 'couriers/';

  static const syncPush = 'sync/push';
  static const syncPull = 'sync/pull';

  static const crmDashboard = 'crm/dashboard/';
  static const crmReport = 'crm/report/';
  static const crmDebts = 'crm/debts/';
  static const crmExpenses = 'crm/expenses/';
  static const crmInventoryAdjust = 'crm/inventory/adjust/';
  static const crmPosCheckout = 'crm/pos/checkout/';


  static String offlineProducts(String apiBaseUrl) => _resolveRoot(apiBaseUrl, 'offline/products/');
  static String offlineSales(String apiBaseUrl) => _resolveRoot(apiBaseUrl, 'offline/sales/');
  static String offlineExpenses(String apiBaseUrl) => _resolveRoot(apiBaseUrl, 'offline/expenses/');
  static String offlineStatus(String apiBaseUrl) => _resolveRoot(apiBaseUrl, 'offline/status/');

  static String _resolveRoot(String apiBaseUrl, String path) {
    final base = Uri.parse(apiBaseUrl);
    var apiPath = base.path;
    if (!apiPath.endsWith('/')) {
      apiPath = '$apiPath/';
    }
    apiPath = apiPath.replaceFirst(RegExp(r'/api/?$'), '/');
    final root = base.replace(path: apiPath);
    return root.resolve(path).toString();
  }
}
