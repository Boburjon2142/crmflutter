import 'package:equatable/equatable.dart';

class CrmCustomer extends Equatable {
  const CrmCustomer({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.discountPercent,
    required this.totalSpent,
    required this.ordersCount,
  });

  final int id;
  final String fullName;
  final String phone;
  final double discountPercent;
  final double totalSpent;
  final int ordersCount;

  @override
  List<Object?> get props => [
        id,
        fullName,
        phone,
        discountPercent,
        totalSpent,
        ordersCount,
      ];
}
