import 'package:json_annotation/json_annotation.dart';

import '../../../domain/catalog/entities/book.dart';
import '../../authors/models/author_model.dart';
import 'category_model.dart';

part 'book_model.g.dart';

@JsonSerializable()
class BookModel {
  BookModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.category,
    required this.author,
    required this.purchasePrice,
    required this.salePrice,
    required this.description,
    required this.bookFormat,
    required this.pages,
    required this.views,
    required this.barcode,
    required this.stockQuantity,
    required this.coverImageUrl,
    required this.createdAt,
  });

  final int id;
  final String title;
  final String slug;
  final CategoryModel? category;
  final AuthorModel? author;
  @JsonKey(name: 'purchase_price', fromJson: _toDouble)
  final double? purchasePrice;
  @JsonKey(name: 'sale_price', fromJson: _toDouble)
  final double? salePrice;
  final String description;
  @JsonKey(name: 'book_format')
  final String? bookFormat;
  final int? pages;
  final int views;
  final String? barcode;
  @JsonKey(name: 'stock_quantity')
  final int stockQuantity;
  @JsonKey(name: 'cover_image_url')
  final String? coverImageUrl;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  factory BookModel.fromJson(Map<String, dynamic> json) =>
      _$BookModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookModelToJson(this);

  Book toEntity() => Book(
        id: id,
        title: title,
        slug: slug,
        category: category?.toEntity(),
        author: author?.toEntity(),
        purchasePrice: purchasePrice,
        salePrice: salePrice,
        description: description,
        bookFormat: bookFormat,
        pages: pages,
        views: views,
        barcode: barcode,
        stockQuantity: stockQuantity,
        coverImageUrl: coverImageUrl,
        createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      );

  static double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}
