import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/crm/entities/debt.dart';
import '../../domain/crm/usecases/create_debt.dart';
import '../../domain/crm/usecases/get_debts.dart';

class CrmDebtsState {
  const CrmDebtsState({
    required this.items,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  final List<CrmDebt> items;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  CrmDebtsState copyWith({
    List<CrmDebt>? items,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
  }) {
    return CrmDebtsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}

class CrmDebtsController extends StateNotifier<CrmDebtsState> {
  CrmDebtsController({
    required GetDebts getDebts,
    required CreateDebt createDebt,
  })  : _getDebts = getDebts,
        _createDebt = createDebt,
        super(const CrmDebtsState(items: []));

  final GetDebts _getDebts;
  final CreateDebt _createDebt;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await _getDebts();
      state = state.copyWith(items: items, isLoading: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> create({
    required String fullName,
    required String amount,
    String? phone,
    String? note,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final debt = await _createDebt(
        fullName: fullName,
        amount: amount,
        phone: phone,
        note: note,
      );
      state = state.copyWith(
        items: [debt, ...state.items],
        isSaving: false,
      );
    } catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: error.toString());
    }
  }
}
