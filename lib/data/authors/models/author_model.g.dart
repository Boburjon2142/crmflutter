// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'author_model.dart';

AuthorModel _$AuthorModelFromJson(Map<String, dynamic> json) => AuthorModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      isFeatured: json['is_featured'] as bool? ?? false,
      photoUrl: json['photo_url'] as String?,
    );

Map<String, dynamic> _$AuthorModelToJson(AuthorModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'bio': instance.bio,
      'is_featured': instance.isFeatured,
      'photo_url': instance.photoUrl,
    };
