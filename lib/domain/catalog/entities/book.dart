import 'package:equatable/equatable.dart';

import 'category.dart';
import '../../authors/entities/author.dart';

class Book extends Equatable {
  const Book({
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
  final Category? category;
  final Author? author;
  final double? purchasePrice;
  final double? salePrice;
  final String description;
  final String? bookFormat;
  final int? pages;
  final int views;
  final String? barcode;
  final int stockQuantity;
  final String? coverImageUrl;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
        id,
        title,
        slug,
        category,
        author,
        purchasePrice,
        salePrice,
        description,
        bookFormat,
        pages,
        views,
        barcode,
        stockQuantity,
        coverImageUrl,
        createdAt,
      ];
}
