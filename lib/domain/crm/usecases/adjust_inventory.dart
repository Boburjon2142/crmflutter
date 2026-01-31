import '../repositories/crm_repository.dart';

class AdjustInventory {
  AdjustInventory(this._repository);

  final CrmRepository _repository;

  Future<void> call({
    required int bookId,
    required int delta,
    String? note,
  }) {
    return _repository.adjustInventory(
      bookId: bookId,
      delta: delta,
      note: note,
    );
  }
}
