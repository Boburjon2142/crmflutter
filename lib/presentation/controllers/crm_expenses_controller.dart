import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/crm/entities/expense.dart';
import '../../domain/crm/usecases/create_expense.dart';
import '../../domain/crm/usecases/get_expenses.dart';

class CrmExpensesState {
  const CrmExpensesState({
    required this.items,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  final List<CrmExpense> items;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  CrmExpensesState copyWith({
    List<CrmExpense>? items,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
  }) {
    return CrmExpensesState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}

class CrmExpensesController extends StateNotifier<CrmExpensesState> {
  CrmExpensesController({
    required GetExpenses getExpenses,
    required CreateExpense createExpense,
  })  : _getExpenses = getExpenses,
        _createExpense = createExpense,
        super(const CrmExpensesState(items: []));

  final GetExpenses _getExpenses;
  final CreateExpense _createExpense;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await _getExpenses();
      state = state.copyWith(items: items, isLoading: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> create({
    required String title,
    required String amount,
    String? spentOn,
    String? note,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final expense = await _createExpense(
        title: title,
        amount: amount,
        spentOn: spentOn,
        note: note,
      );
      state = state.copyWith(
        items: [expense, ...state.items],
        isSaving: false,
      );
    } catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: error.toString());
    }
  }
}
