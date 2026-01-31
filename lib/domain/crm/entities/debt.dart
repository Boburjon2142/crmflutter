import 'package:equatable/equatable.dart';

class CrmDebt extends Equatable {
  const CrmDebt({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.amount,
    required this.paidAmount,
    required this.isPaid,
    required this.note,
    required this.createdAt,
  });

  final int id;
  final String fullName;
  final String phone;
  final double amount;
  final double paidAmount;
  final bool isPaid;
  final String note;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
        id,
        fullName,
        phone,
        amount,
        paidAmount,
        isPaid,
        note,
        createdAt,
      ];
}
