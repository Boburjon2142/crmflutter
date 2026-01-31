// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      status: json['status'] as String? ?? '',
      orderSource: json['order_source'] as String? ?? '',
      totalPrice: _toDouble(json['total_price']),
      createdAt: json['created_at'] as String?,
      items: json['items'] as List<dynamic>? ?? [],
    );

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'phone': instance.phone,
      'status': instance.status,
      'order_source': instance.orderSource,
      'total_price': instance.totalPrice,
      'created_at': instance.createdAt,
      'items': instance.items,
    };
