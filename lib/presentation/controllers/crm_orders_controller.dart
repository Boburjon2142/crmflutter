import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/crm/entities/order.dart';
import '../../domain/crm/usecases/get_orders.dart';

class CrmOrdersQuery extends Equatable {
  const CrmOrdersQuery({this.status});

  final String? status;

  @override
  List<Object?> get props => [status];
}

class CrmOrdersState {
  const CrmOrdersState({
    required this.items,
    required this.page,
    required this.hasNext,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<CrmOrder> items;
  final int page;
  final bool hasNext;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  CrmOrdersState copyWith({
    List<CrmOrder>? items,
    int? page,
    bool? hasNext,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return CrmOrdersState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasNext: hasNext ?? this.hasNext,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
    );
  }
}

class CrmOrdersController extends StateNotifier<CrmOrdersState> {
  CrmOrdersController({
    required GetOrders getOrders,
    required CrmOrdersQuery query,
  })  : _getOrders = getOrders,
        _query = query,
        super(const CrmOrdersState(items: [], page: 1, hasNext: true));

  final GetOrders _getOrders;
  final CrmOrdersQuery _query;

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _getOrders(
        page: 1,
        status: _query.status,
      );
      state = state.copyWith(
        items: response.results,
        page: 1,
        hasNext: response.next != null,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> refresh() => loadInitial();

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasNext) {
      return;
    }
    state = state.copyWith(isLoadingMore: true, errorMessage: null);
    try {
      final nextPage = state.page + 1;
      final response = await _getOrders(
        page: nextPage,
        status: _query.status,
      );
      state = state.copyWith(
        items: [...state.items, ...response.results],
        page: nextPage,
        hasNext: response.next != null,
        isLoadingMore: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: error.toString(),
      );
    }
  }
}
