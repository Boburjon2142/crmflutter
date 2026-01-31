import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/authors/entities/author.dart';
import '../../domain/authors/usecases/get_authors.dart';

class AuthorsState {
  const AuthorsState({
    required this.items,
    required this.page,
    required this.hasNext,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<Author> items;
  final int page;
  final bool hasNext;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  AuthorsState copyWith({
    List<Author>? items,
    int? page,
    bool? hasNext,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return AuthorsState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasNext: hasNext ?? this.hasNext,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
    );
  }
}

class AuthorsController extends StateNotifier<AuthorsState> {
  AuthorsController({required GetAuthors getAuthors})
      : _getAuthors = getAuthors,
        super(const AuthorsState(items: [], page: 1, hasNext: true));

  final GetAuthors _getAuthors;

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _getAuthors(page: 1);
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

  Future<void> refresh() async {
    await loadInitial();
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasNext) {
      return;
    }
    state = state.copyWith(isLoadingMore: true, errorMessage: null);
    try {
      final nextPage = state.page + 1;
      final response = await _getAuthors(page: nextPage);
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
