import 'package:json_annotation/json_annotation.dart';

import '../../../domain/auth/entities/token.dart';

part 'token_model.g.dart';

@JsonSerializable()
class TokenModel {
  TokenModel({
    required this.access,
    required this.refresh,
  });

  final String access;
  final String refresh;

  factory TokenModel.fromJson(Map<String, dynamic> json) =>
      _$TokenModelFromJson(json);

  Map<String, dynamic> toJson() => _$TokenModelToJson(this);

  AuthToken toEntity() => AuthToken(access: access, refresh: refresh);

  static TokenModel fromEntity(AuthToken token) =>
      TokenModel(access: token.access, refresh: token.refresh);
}
