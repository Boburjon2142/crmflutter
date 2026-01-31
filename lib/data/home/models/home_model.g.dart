// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_model.dart';

HomeSectionModel _$HomeSectionModelFromJson(Map<String, dynamic> json) =>
    HomeSectionModel(
      title: json['title'] as String? ?? '',
      category:
          CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      books: (json['books'] as List<dynamic>? ?? [])
          .map((item) => BookModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HomeSectionModelToJson(HomeSectionModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'category': instance.category,
      'books': instance.books,
    };

HomeModel _$HomeModelFromJson(Map<String, dynamic> json) => HomeModel(
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      authors: (json['authors'] as List<dynamic>? ?? [])
          .map((item) => AuthorModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      banners: (json['banners'] as List<dynamic>? ?? [])
          .map((item) => BannerModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      featuredSections: (json['featured_sections'] as List<dynamic>? ?? [])
          .map((item) => HomeSectionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      bestSelling: (json['best_selling'] as List<dynamic>? ?? [])
          .map((item) => BookModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      newBooks: (json['new_books'] as List<dynamic>? ?? [])
          .map((item) => BookModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      recommended: (json['recommended'] as List<dynamic>? ?? [])
          .map((item) => BookModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HomeModelToJson(HomeModel instance) => <String, dynamic>{
      'categories': instance.categories,
      'authors': instance.authors,
      'banners': instance.banners,
      'featured_sections': instance.featuredSections,
      'best_selling': instance.bestSelling,
      'new_books': instance.newBooks,
      'recommended': instance.recommended,
    };
