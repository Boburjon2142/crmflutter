part of 'customer_model.dart';

CustomerModel _$CustomerModelFromJson(Map<String, dynamic> json) => CustomerModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      discountPercent: _toDouble(json['discount_percent']),
      totalSpent: _toDouble(json['total_spent']),
      ordersCount: (json['orders_count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CustomerModelToJson(CustomerModel instance) => <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'phone': instance.phone,
      'discount_percent': instance.discountPercent,
      'total_spent': instance.totalSpent,
      'orders_count': instance.ordersCount,
    };
