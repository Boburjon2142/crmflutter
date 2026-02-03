import 'package:json_annotation/json_annotation.dart';

import '../../../domain/crm/entities/debt.dart';

part 'debt_model.g.dart';

@JsonSerializable()
class DebtModel {
  DebtModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.amount,
    required this.paidAmount,
    required this.isPaid,
    required this.note,
    required this.createdAt,
    required this.orderItems,
  });

  final int id;
  @JsonKey(name: 'full_name')
  final String fullName;
  final String phone;
  @JsonKey(fromJson: _toDouble)
  final double amount;
  @JsonKey(name: 'paid_amount', fromJson: _toDouble)
  final double paidAmount;
  @JsonKey(name: 'is_paid')
  final bool isPaid;
  final String note;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'order_items')
  final List<DebtOrderItemModel> orderItems;

  factory DebtModel.fromJson(Map<String, dynamic> json) =>
      _$DebtModelFromJson(json);

  Map<String, dynamic> toJson() => _$DebtModelToJson(this);

  CrmDebt toEntity() => CrmDebt(
        id: id,
        fullName: fullName,
        phone: phone,
        amount: amount,
        paidAmount: paidAmount,
        isPaid: isPaid,
        note: note,
        createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
        orderItems: orderItems.map((item) => item.toEntity()).toList(),
      );
}

@JsonSerializable()
class DebtOrderItemModel {
  DebtOrderItemModel({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });

  final int id;
  @JsonKey(name: 'book')
  final String title;
  final int quantity;
  @JsonKey(fromJson: _toDouble)
  final double price;

  factory DebtOrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$DebtOrderItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$DebtOrderItemModelToJson(this);

  CrmDebtOrderItem toEntity() => CrmDebtOrderItem(
        id: id,
        title: title,
        quantity: quantity,
        price: price,
      );
}

double _toDouble(dynamic value) {
  if (value == null) {
    return 0;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? 0;
  }
  return 0;
}
