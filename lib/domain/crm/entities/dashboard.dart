import 'package:equatable/equatable.dart';

class CrmHourly extends Equatable {
  const CrmHourly({required this.label, required this.total});

  final String label;
  final double total;

  @override
  List<Object?> get props => [label, total];
}

class CrmTopBook extends Equatable {
  const CrmTopBook({
    required this.title,
    required this.quantity,
    required this.revenue,
  });

  final String title;
  final int quantity;
  final double revenue;

  @override
  List<Object?> get props => [title, quantity, revenue];
}

class CrmDashboard extends Equatable {
  const CrmDashboard({
    required this.ordersToday,
    required this.revenueToday,
    required this.weeklyOrders,
    required this.weeklyRevenue,
    required this.hourly,
    required this.topBooks,
  });

  final int ordersToday;
  final double revenueToday;
  final int weeklyOrders;
  final double weeklyRevenue;
  final List<CrmHourly> hourly;
  final List<CrmTopBook> topBooks;

  @override
  List<Object?> get props => [
        ordersToday,
        revenueToday,
        weeklyOrders,
        weeklyRevenue,
        hourly,
        topBooks,
      ];
}
