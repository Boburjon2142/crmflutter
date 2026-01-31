import 'package:json_annotation/json_annotation.dart';

import '../../../domain/crm/entities/dashboard.dart';

part 'dashboard_model.g.dart';

@JsonSerializable()
class CrmHourlyModel {
  CrmHourlyModel({
    required this.label,
    required this.total,
  });

  final String label;
  @JsonKey(fromJson: _toDouble)
  final double total;

  factory CrmHourlyModel.fromJson(Map<String, dynamic> json) =>
      _$CrmHourlyModelFromJson(json);

  Map<String, dynamic> toJson() => _$CrmHourlyModelToJson(this);

  CrmHourly toEntity() => CrmHourly(label: label, total: total);
}

@JsonSerializable()
class CrmTopBookModel {
  CrmTopBookModel({
    required this.title,
    required this.quantity,
    required this.revenue,
  });

  @JsonKey(name: 'book__title')
  final String title;
  final int quantity;
  @JsonKey(fromJson: _toDouble)
  final double revenue;

  factory CrmTopBookModel.fromJson(Map<String, dynamic> json) =>
      _$CrmTopBookModelFromJson(json);

  Map<String, dynamic> toJson() => _$CrmTopBookModelToJson(this);

  CrmTopBook toEntity() => CrmTopBook(
        title: title,
        quantity: quantity,
        revenue: revenue,
      );
}

@JsonSerializable()
class CrmDashboardModel {
  CrmDashboardModel({
    required this.ordersToday,
    required this.revenueToday,
    required this.weeklyOrders,
    required this.weeklyRevenue,
    required this.hourly,
    required this.topBooks,
  });

  @JsonKey(name: 'orders_today')
  final int ordersToday;
  @JsonKey(name: 'revenue_today', fromJson: _toDouble)
  final double revenueToday;
  @JsonKey(name: 'weekly_orders')
  final int weeklyOrders;
  @JsonKey(name: 'weekly_revenue', fromJson: _toDouble)
  final double weeklyRevenue;
  final List<CrmHourlyModel> hourly;
  @JsonKey(name: 'top_books')
  final List<CrmTopBookModel> topBooks;

  factory CrmDashboardModel.fromJson(Map<String, dynamic> json) =>
      _$CrmDashboardModelFromJson(json);

  Map<String, dynamic> toJson() => _$CrmDashboardModelToJson(this);

  CrmDashboard toEntity() => CrmDashboard(
        ordersToday: ordersToday,
        revenueToday: revenueToday,
        weeklyOrders: weeklyOrders,
        weeklyRevenue: weeklyRevenue,
        hourly: hourly.map((item) => item.toEntity()).toList(),
        topBooks: topBooks.map((item) => item.toEntity()).toList(),
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
