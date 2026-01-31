import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/crm/usecases/get_report.dart';

class CrmReportState {
  const CrmReportState({
    this.data,
    this.isLoading = false,
    this.errorMessage,
  });

  final Map<String, dynamic>? data;
  final bool isLoading;
  final String? errorMessage;

  CrmReportState copyWith({
    Map<String, dynamic>? data,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CrmReportState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class CrmReportController extends StateNotifier<CrmReportState> {
  CrmReportController({required GetCrmReport getReport})
      : _getReport = getReport,
        super(const CrmReportState());

  final GetCrmReport _getReport;

  Future<void> load({
    String? start,
    String? end,
    String? startTime,
    String? endTime,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final data = await _getReport(
        start: start,
        end: end,
        startTime: startTime,
        endTime: endTime,
      );
      state = state.copyWith(data: data, isLoading: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }
}
