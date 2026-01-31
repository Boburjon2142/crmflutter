import 'package:equatable/equatable.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.parentId,
  });

  final int id;
  final String name;
  final String slug;
  final int? parentId;

  @override
  List<Object?> get props => [id, name, slug, parentId];
}
