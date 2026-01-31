import 'package:json_annotation/json_annotation.dart';

import '../../../domain/crm/entities/courier.dart';

part 'courier_model.g.dart';

@JsonSerializable()
class CourierModel {
  CourierModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.telegramUsername,
    required this.isActive,
  });

  final int id;
  final String name;
  final String phone;
  @JsonKey(name: 'telegram_username')
  final String telegramUsername;
  @JsonKey(name: 'is_active')
  final bool isActive;

  factory CourierModel.fromJson(Map<String, dynamic> json) =>
      _$CourierModelFromJson(json);

  Map<String, dynamic> toJson() => _$CourierModelToJson(this);

  CrmCourier toEntity() => CrmCourier(
        id: id,
        name: name,
        phone: phone,
        telegramUsername: telegramUsername,
        isActive: isActive,
      );
}
