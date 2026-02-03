// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt_model.dart';

DebtModel _$DebtModelFromJson(Map<String, dynamic> json) => DebtModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      amount: _toDouble(json['amount']),
      paidAmount: _toDouble(json['paid_amount']),
      isPaid: json['is_paid'] as bool? ?? false,
      note: json['note'] as String? ?? '',
      createdAt: json['created_at'] as String?,
      orderItems: (json['order_items'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(DebtOrderItemModel.fromJson)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DebtModelToJson(DebtModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'phone': instance.phone,
      'amount': instance.amount,
      'paid_amount': instance.paidAmount,
      'is_paid': instance.isPaid,
      'note': instance.note,
      'created_at': instance.createdAt,
      'order_items': instance.orderItems.map((e) => e.toJson()).toList(),
    };

DebtOrderItemModel _$DebtOrderItemModelFromJson(Map<String, dynamic> json) =>
    DebtOrderItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['book'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      price: _toDouble(json['price']),
    );

Map<String, dynamic> _$DebtOrderItemModelToJson(DebtOrderItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'book': instance.title,
      'quantity': instance.quantity,
      'price': instance.price,
    };
