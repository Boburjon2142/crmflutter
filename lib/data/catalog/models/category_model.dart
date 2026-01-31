import 'package:json_annotation/json_annotation.dart';

import '../../../domain/catalog/entities/category.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel {
  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.parentId,
  });

  final int id;
  final String name;
  final String slug;
  @JsonKey(name: 'parent_id')
  final int? parentId;

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  Category toEntity() => Category(
        id: id,
        name: name,
        slug: slug,
        parentId: parentId,
      );
}
