import 'package:json_annotation/json_annotation.dart';

import '../../../domain/crm/entities/order.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderModel {
  OrderModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.status,
    required this.orderSource,
    required this.totalPrice,
    required this.createdAt,
    required this.items,
  });

  final int id;
  @JsonKey(name: 'full_name')
  final String fullName;
  final String phone;
  final String status;
  @JsonKey(name: 'order_source')
  final String orderSource;
  @JsonKey(name: 'total_price', fromJson: _toDouble)
  final double totalPrice;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  final List<OrderItemModel> items;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  CrmOrder toEntity() => CrmOrder(
        id: id,
        fullName: fullName,
        phone: phone,
        status: status,
        orderSource: orderSource,
        totalPrice: totalPrice,
        createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
        itemsCount: items.length,
        items: items.map((item) => item.toEntity()).toList(),
      );
}

@JsonSerializable()
class OrderItemModel {
  OrderItemModel({
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

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);

  CrmOrderItem toEntity() => CrmOrderItem(
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
