import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/catalog/entities/book.dart';
import '../../domain/crm/usecases/create_pos_order.dart';

class PosItem {
  PosItem({required this.book, required this.quantity});

  final Book book;
  int quantity;

  double get total => (book.salePrice ?? 0) * quantity;
}

class CrmPosState {
  const CrmPosState({
    required this.items,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final List<PosItem> items;
  final bool isSubmitting;
  final String? errorMessage;

  CrmPosState copyWith({
    List<PosItem>? items,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return CrmPosState(
      items: items ?? this.items,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

class CrmPosController extends StateNotifier<CrmPosState> {
  CrmPosController({required CreatePosOrder createPosOrder})
      : _createPosOrder = createPosOrder,
        super(const CrmPosState(items: []));

  final CreatePosOrder _createPosOrder;

  void addBook(Book book) {
    final existing = state.items.where((item) => item.book.id == book.id).toList();
    if (existing.isNotEmpty) {
      existing.first.quantity += 1;
      state = state.copyWith(items: List<PosItem>.from(state.items));
      return;
    }
    state = state.copyWith(items: [...state.items, PosItem(book: book, quantity: 1)]);
  }

  void updateQuantity(Book book, int quantity) {
    final items = state.items.map((item) {
      if (item.book.id == book.id) {
        item.quantity = quantity;
      }
      return item;
    }).where((item) => item.quantity > 0).toList();
    state = state.copyWith(items: items);
  }

  void remove(Book book) {
    state = state.copyWith(
      items: state.items.where((item) => item.book.id != book.id).toList(),
    );
  }

  double get total =>
      state.items.fold(0, (sum, item) => sum + item.total);

  Future<void> submit({
    String? fullName,
    String? phone,
    String? paymentType,
    String? discountAmount,
  }) async {
    if (state.items.isEmpty) {
      return;
    }
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final payload = state.items
          .map(
            (item) => {
              'book_id': item.book.id,
              'quantity': item.quantity,
              'price': item.book.salePrice ?? 0,
            },
          )
          .toList();
      await _createPosOrder(
        items: payload,
        fullName: fullName,
        phone: phone,
        paymentType: paymentType,
        discountAmount: discountAmount,
      );
      state = state.copyWith(items: [], isSubmitting: false);
    } catch (error) {
      state = state.copyWith(isSubmitting: false, errorMessage: error.toString());
    }
  }
}
