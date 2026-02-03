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
    this.orderItems = const [],
  });

  final int id;
  final String fullName;
  final String phone;
  final double amount;
  final double paidAmount;
  final bool isPaid;
  final String note;
  final DateTime? createdAt;
  final List<CrmDebtOrderItem> orderItems;

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
        orderItems,
      ];
}

class CrmDebtOrderItem extends Equatable {
  const CrmDebtOrderItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });

  final int id;
  final String title;
  final int quantity;
  final double price;

  @override
  List<Object?> get props => [id, title, quantity, price];
}
