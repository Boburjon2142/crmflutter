// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_model.dart';

BookModel _$BookModelFromJson(Map<String, dynamic> json) => BookModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      category: json['category'] == null
          ? null
          : CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      author: json['author'] == null
          ? null
          : AuthorModel.fromJson(json['author'] as Map<String, dynamic>),
      purchasePrice: BookModel._toDouble(json['purchase_price']),
      salePrice: BookModel._toDouble(json['sale_price']),
      description: json['description'] as String? ?? '',
      bookFormat: json['book_format'] as String?,
      pages: (json['pages'] as num?)?.toInt(),
      views: (json['views'] as num?)?.toInt() ?? 0,
      barcode: json['barcode'] as String?,
      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,
      coverImageUrl: json['cover_image_url'] as String?,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$BookModelToJson(BookModel instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'slug': instance.slug,
      'category': instance.category,
      'author': instance.author,
      'purchase_price': instance.purchasePrice,
      'sale_price': instance.salePrice,
      'description': instance.description,
      'book_format': instance.bookFormat,
      'pages': instance.pages,
      'views': instance.views,
      'barcode': instance.barcode,
      'stock_quantity': instance.stockQuantity,
      'cover_image_url': instance.coverImageUrl,
      'created_at': instance.createdAt,
    };
