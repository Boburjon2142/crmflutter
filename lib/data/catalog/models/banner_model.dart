import 'package:json_annotation/json_annotation.dart';

import '../../../domain/catalog/entities/banner.dart';

part 'banner_model.g.dart';

@JsonSerializable()
class BannerModel {
  BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.link,
  });

  final int id;
  final String title;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final String? link;

  factory BannerModel.fromJson(Map<String, dynamic> json) =>
      _$BannerModelFromJson(json);

  Map<String, dynamic> toJson() => _$BannerModelToJson(this);

  BannerItem toEntity() => BannerItem(
        id: id,
        title: title,
        imageUrl: imageUrl,
        link: link,
      );
}
