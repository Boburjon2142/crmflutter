import 'package:json_annotation/json_annotation.dart';

import '../../../domain/crm/entities/expense.dart';

part 'expense_model.g.dart';

@JsonSerializable()
class ExpenseModel {
  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.spentOn,
    required this.note,
    required this.createdAt,
  });

  final int id;
  final String title;
  @JsonKey(fromJson: _toDouble)
  final double amount;
  @JsonKey(name: 'spent_on')
  final String? spentOn;
  final String note;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  factory ExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseModelToJson(this);

  CrmExpense toEntity() => CrmExpense(
        id: id,
        title: title,
        amount: amount,
        spentOn: spentOn != null ? DateTime.tryParse(spentOn!) : null,
        note: note,
        createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
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
