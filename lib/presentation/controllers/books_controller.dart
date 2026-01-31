import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/catalog/entities/book.dart';
import '../../domain/catalog/usecases/get_books.dart';

class BooksQuery extends Equatable {
  const BooksQuery({
    this.query,
    this.categoryId,
    this.categorySlug,
    this.sort,
    this.authorId,
  });

  final String? query;
  final int? categoryId;
  final String? categorySlug;
  final String? sort;
  final int? authorId;

  @override
  List<Object?> get props => [query, categoryId, categorySlug, sort, authorId];
}

class BooksState {
  const BooksState({
    required this.items,
    required this.page,
    required this.hasNext,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<Book> items;
  final int page;
  final bool hasNext;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  BooksState copyWith({
    List<Book>? items,
    int? page,
    bool? hasNext,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return BooksState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasNext: hasNext ?? this.hasNext,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
    );
  }
}

class BooksController extends StateNotifier<BooksState> {
  BooksController({
    required GetBooks getBooks,
    required BooksQuery query,
  })  : _getBooks = getBooks,
        _query = query,
        super(const BooksState(items: [], page: 1, hasNext: true));

  final GetBooks _getBooks;
  final BooksQuery _query;

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _getBooks(
        page: 1,
        query: _query.query,
        categoryId: _query.categoryId,
        categorySlug: _query.categorySlug,
        sort: _query.sort,
        authorId: _query.authorId,
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
      final response = await _getBooks(
        page: nextPage,
        query: _query.query,
        categoryId: _query.categoryId,
        categorySlug: _query.categorySlug,
        sort: _query.sort,
        authorId: _query.authorId,
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
