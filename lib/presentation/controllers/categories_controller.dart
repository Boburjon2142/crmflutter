import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/catalog/entities/category.dart';
import '../../domain/catalog/usecases/get_categories.dart';

class CategoriesState {
  const CategoriesState({
    required this.items,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<Category> items;
  final bool isLoading;
  final String? errorMessage;

  CategoriesState copyWith({
    List<Category>? items,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CategoriesState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class CategoriesController extends StateNotifier<CategoriesState> {
  CategoriesController({required GetCategories getCategories})
      : _getCategories = getCategories,
        super(const CategoriesState(items: []));

  final GetCategories _getCategories;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await _getCategories();
      state = state.copyWith(items: items, isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> refresh() => load();
}
