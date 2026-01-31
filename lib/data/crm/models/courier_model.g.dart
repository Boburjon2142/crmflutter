part of 'courier_model.dart';

CourierModel _$CourierModelFromJson(Map<String, dynamic> json) => CourierModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      telegramUsername: json['telegram_username'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? false,
    );

Map<String, dynamic> _$CourierModelToJson(CourierModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'telegram_username': instance.telegramUsername,
      'is_active': instance.isActive,
    };
