import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/catalog/entities/book.dart';
import '../../domain/crm/usecases/get_books.dart';

class CrmBooksState {
  const CrmBooksState({
    required this.items,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<Book> items;
  final bool isLoading;
  final String? errorMessage;

  CrmBooksState copyWith({
    List<Book>? items,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CrmBooksState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class CrmBooksController extends StateNotifier<CrmBooksState> {
  CrmBooksController({
    required GetCrmBooks getBooks,
    String? query,
  })  : _getBooks = getBooks,
        _query = query,
        super(const CrmBooksState(items: []));

  final GetCrmBooks _getBooks;
  final String? _query;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await _getBooks(query: _query);
      state = state.copyWith(items: items, isLoading: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }
}
