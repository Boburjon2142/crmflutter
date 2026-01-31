import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/crm/entities/dashboard.dart';
import '../../domain/crm/usecases/get_dashboard.dart';

class CrmDashboardState {
  const CrmDashboardState({
    this.data,
    this.isLoading = false,
    this.errorMessage,
  });

  final CrmDashboard? data;
  final bool isLoading;
  final String? errorMessage;

  CrmDashboardState copyWith({
    CrmDashboard? data,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CrmDashboardState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class CrmDashboardController extends StateNotifier<CrmDashboardState> {
  CrmDashboardController({required GetDashboard getDashboard})
      : _getDashboard = getDashboard,
        super(const CrmDashboardState());

  final GetDashboard _getDashboard;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final data = await _getDashboard();
      state = state.copyWith(data: data, isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }
}
