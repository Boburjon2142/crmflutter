import 'package:equatable/equatable.dart';

class CrmOrder extends Equatable {
  const CrmOrder({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.status,
    required this.orderSource,
    required this.totalPrice,
    required this.createdAt,
    required this.itemsCount,
    this.items = const [],
  });

  final int id;
  final String fullName;
  final String phone;
  final String status;
  final String orderSource;
  final double totalPrice;
  final DateTime? createdAt;
  final int itemsCount;
  final List<CrmOrderItem> items;

  @override
  List<Object?> get props => [
        id,
        fullName,
        phone,
        status,
        orderSource,
        totalPrice,
        createdAt,
        itemsCount,
        items,
      ];
}

class CrmOrderItem extends Equatable {
  const CrmOrderItem({
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
