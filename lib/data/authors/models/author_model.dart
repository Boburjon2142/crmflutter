import 'package:json_annotation/json_annotation.dart';

import '../../../domain/authors/entities/author.dart';

part 'author_model.g.dart';

@JsonSerializable()
class AuthorModel {
  AuthorModel({
    required this.id,
    required this.name,
    required this.bio,
    required this.isFeatured,
    required this.photoUrl,
  });

  final int id;
  final String name;
  final String bio;

  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @JsonKey(name: 'photo_url')
  final String? photoUrl;

  factory AuthorModel.fromJson(Map<String, dynamic> json) =>
      _$AuthorModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorModelToJson(this);

  Author toEntity() => Author(
        id: id,
        name: name,
        bio: bio,
        isFeatured: isFeatured,
        photoUrl: photoUrl,
      );
}
