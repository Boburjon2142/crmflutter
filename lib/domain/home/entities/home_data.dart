import 'package:equatable/equatable.dart';

import '../../authors/entities/author.dart';
import '../../catalog/entities/banner.dart';
import '../../catalog/entities/book.dart';
import '../../catalog/entities/category.dart';

class HomeSection extends Equatable {
  const HomeSection({
    required this.title,
    required this.category,
    required this.books,
  });

  final String title;
  final Category category;
  final List<Book> books;

  @override
  List<Object?> get props => [title, category, books];
}

class HomeData extends Equatable {
  const HomeData({
    required this.categories,
    required this.authors,
    required this.banners,
    required this.featuredSections,
    required this.bestSelling,
    required this.newBooks,
    required this.recommended,
  });

  final List<Category> categories;
  final List<Author> authors;
  final List<BannerItem> banners;
  final List<HomeSection> featuredSections;
  final List<Book> bestSelling;
  final List<Book> newBooks;
  final List<Book> recommended;

  @override
  List<Object?> get props => [
        categories,
        authors,
        banners,
        featuredSections,
        bestSelling,
        newBooks,
        recommended,
      ];
}
