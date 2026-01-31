import 'package:json_annotation/json_annotation.dart';

import '../../../domain/home/entities/home_data.dart';
import '../../authors/models/author_model.dart';
import '../../catalog/models/banner_model.dart';
import '../../catalog/models/book_model.dart';
import '../../catalog/models/category_model.dart';

part 'home_model.g.dart';

@JsonSerializable()
class HomeSectionModel {
  HomeSectionModel({
    required this.title,
    required this.category,
    required this.books,
  });

  final String title;
  final CategoryModel category;
  final List<BookModel> books;

  factory HomeSectionModel.fromJson(Map<String, dynamic> json) =>
      _$HomeSectionModelFromJson(json);

  Map<String, dynamic> toJson() => _$HomeSectionModelToJson(this);

  HomeSection toEntity() => HomeSection(
        title: title,
        category: category.toEntity(),
        books: books.map((item) => item.toEntity()).toList(),
      );
}

@JsonSerializable()
class HomeModel {
  HomeModel({
    required this.categories,
    required this.authors,
    required this.banners,
    required this.featuredSections,
    required this.bestSelling,
    required this.newBooks,
    required this.recommended,
  });

  final List<CategoryModel> categories;
  final List<AuthorModel> authors;
  final List<BannerModel> banners;
  @JsonKey(name: 'featured_sections')
  final List<HomeSectionModel> featuredSections;
  @JsonKey(name: 'best_selling')
  final List<BookModel> bestSelling;
  @JsonKey(name: 'new_books')
  final List<BookModel> newBooks;
  final List<BookModel> recommended;

  factory HomeModel.fromJson(Map<String, dynamic> json) =>
      _$HomeModelFromJson(json);

  Map<String, dynamic> toJson() => _$HomeModelToJson(this);

  HomeData toEntity() => HomeData(
        categories: categories.map((item) => item.toEntity()).toList(),
        authors: authors.map((item) => item.toEntity()).toList(),
        banners: banners.map((item) => item.toEntity()).toList(),
        featuredSections: featuredSections.map((item) => item.toEntity()).toList(),
        bestSelling: bestSelling.map((item) => item.toEntity()).toList(),
        newBooks: newBooks.map((item) => item.toEntity()).toList(),
        recommended: recommended.map((item) => item.toEntity()).toList(),
      );
}
