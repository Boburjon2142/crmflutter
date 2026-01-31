import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/crm/entities/search.dart';
import '../../domain/crm/usecases/search.dart';

class CrmSearchState {
  const CrmSearchState({
    this.result,
    this.isLoading = false,
    this.errorMessage,
  });

  final CrmSearchResult? result;
  final bool isLoading;
  final String? errorMessage;

  CrmSearchState copyWith({
    CrmSearchResult? result,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CrmSearchState(
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class CrmSearchController extends StateNotifier<CrmSearchState> {
  CrmSearchController({required CrmSearch search})
      : _search = search,
        super(const CrmSearchState());

  final CrmSearch _search;

  Future<void> run(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(result: null, isLoading: false);
      return;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _search(query);
      state = state.copyWith(result: result, isLoading: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }
}
