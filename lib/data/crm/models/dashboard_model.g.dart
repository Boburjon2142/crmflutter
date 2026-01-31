// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_model.dart';

CrmHourlyModel _$CrmHourlyModelFromJson(Map<String, dynamic> json) =>
    CrmHourlyModel(
      label: json['label'] as String? ?? '',
      total: _toDouble(json['total']),
    );

Map<String, dynamic> _$CrmHourlyModelToJson(CrmHourlyModel instance) =>
    <String, dynamic>{
      'label': instance.label,
      'total': instance.total,
    };

CrmTopBookModel _$CrmTopBookModelFromJson(Map<String, dynamic> json) =>
    CrmTopBookModel(
      title: json['book__title'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      revenue: _toDouble(json['revenue']),
    );

Map<String, dynamic> _$CrmTopBookModelToJson(CrmTopBookModel instance) =>
    <String, dynamic>{
      'book__title': instance.title,
      'quantity': instance.quantity,
      'revenue': instance.revenue,
    };

CrmDashboardModel _$CrmDashboardModelFromJson(Map<String, dynamic> json) =>
    CrmDashboardModel(
      ordersToday: (json['orders_today'] as num?)?.toInt() ?? 0,
      revenueToday: _toDouble(json['revenue_today']),
      weeklyOrders: (json['weekly_orders'] as num?)?.toInt() ?? 0,
      weeklyRevenue: _toDouble(json['weekly_revenue']),
      hourly: (json['hourly'] as List<dynamic>? ?? [])
          .map((item) => CrmHourlyModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      topBooks: (json['top_books'] as List<dynamic>? ?? [])
          .map((item) => CrmTopBookModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CrmDashboardModelToJson(CrmDashboardModel instance) =>
    <String, dynamic>{
      'orders_today': instance.ordersToday,
      'revenue_today': instance.revenueToday,
      'weekly_orders': instance.weeklyOrders,
      'weekly_revenue': instance.weeklyRevenue,
      'hourly': instance.hourly,
      'top_books': instance.topBooks,
    };
