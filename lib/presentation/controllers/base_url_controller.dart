import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/api_config.dart';
import '../../core/config/env.dart';

class BaseUrlController extends StateNotifier<String> {
  BaseUrlController({
    required ApiConfig config,
    required String initial,
  })  : _config = config,
        super(initial);

  final ApiConfig _config;

  Future<void> load() async {
    final value = await _config.loadBaseUrl();
    if (kReleaseMode) {
      final enforced = _config.normalize(Env.baseUrl);
      if (value != enforced) {
        await _config.saveBaseUrl(enforced);
        state = enforced;
        return;
      }
    }
    state = value;
  }

  Future<void> update(String value) async {
    final normalized = _config.normalize(value);
    await _config.saveBaseUrl(normalized);
    state = normalized;
  }
}
