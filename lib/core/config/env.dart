import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get baseUrl {
    final raw = dotenv.env['BASE_URL']?.trim();
    final fallback = 'https://bilimcrm.uz/api/';
    if (raw == null || raw.isEmpty) {
      return fallback;
    }
    return raw.endsWith('/') ? raw : '$raw/';
  }
}
