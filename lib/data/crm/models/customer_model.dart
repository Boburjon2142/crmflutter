import 'package:json_annotation/json_annotation.dart';

import '../../../domain/crm/entities/customer.dart';

part 'customer_model.g.dart';

@JsonSerializable()
class CustomerModel {
  CustomerModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.discountPercent,
    required this.totalSpent,
    required this.ordersCount,
  });

  final int id;
  @JsonKey(name: 'full_name')
  final String fullName;
  final String phone;
  @JsonKey(name: 'discount_percent', fromJson: _toDouble)
  final double discountPercent;
  @JsonKey(name: 'total_spent', fromJson: _toDouble)
  final double totalSpent;
  @JsonKey(name: 'orders_count')
  final int ordersCount;

  factory CustomerModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerModelFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerModelToJson(this);

  CrmCustomer toEntity() => CrmCustomer(
        id: id,
        fullName: fullName,
        phone: phone,
        discountPercent: discountPercent,
        totalSpent: totalSpent,
        ordersCount: ordersCount,
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
