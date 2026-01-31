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
    };
