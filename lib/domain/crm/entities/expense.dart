import 'package:equatable/equatable.dart';

class CrmExpense extends Equatable {
  const CrmExpense({
    required this.id,
    required this.title,
    required this.amount,
    required this.spentOn,
    required this.note,
    required this.createdAt,
  });

  final int id;
  final String title;
  final double amount;
  final DateTime? spentOn;
  final String note;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, title, amount, spentOn, note, createdAt];
}
