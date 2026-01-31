// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

ExpenseModel _$ExpenseModelFromJson(Map<String, dynamic> json) => ExpenseModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      amount: _toDouble(json['amount']),
      spentOn: json['spent_on'] as String?,
      note: json['note'] as String? ?? '',
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$ExpenseModelToJson(ExpenseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'amount': instance.amount,
      'spent_on': instance.spentOn,
      'note': instance.note,
      'created_at': instance.createdAt,
    };
