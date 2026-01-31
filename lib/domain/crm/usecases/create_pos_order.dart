import '../repositories/crm_repository.dart';

class CreatePosOrder {
  CreatePosOrder(this._repository);

  final CrmRepository _repository;

  Future<Map<String, dynamic>> call({
    required List<Map<String, dynamic>> items,
    String? fullName,
    String? phone,
    String? paymentType,
    String? discountAmount,
  }) {
    return _repository.createPosOrder(
      items: items,
      fullName: fullName,
      phone: phone,
      paymentType: paymentType,
      discountAmount: discountAmount,
    );
  }
}
