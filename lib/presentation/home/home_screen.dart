import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/authors/entities/author.dart';
import '../../domain/catalog/entities/book.dart';
import '../../domain/catalog/entities/category.dart';
import '../../domain/home/entities/home_data.dart';
import '../../domain/catalog/entities/banner.dart';
import '../authors/author_detail_screen.dart';
import '../authors/authors_list_screen.dart';
import '../catalog/categories_screen.dart';
import '../catalog/category_books_screen.dart';
import '../controllers/home_controller.dart';
import '../providers.dart';
import '../search/search_screen.dart';
import '../shared/book_detail_screen.dart';
import '../ui/formatters.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(homeControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);

    if (state.isLoading && state.data == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.errorMessage != null && state.data == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () =>
                      ref.read(homeControllerProvider.notifier).load(),
                  child: const Text('Qayta urinish'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final data = state.data;
    return Scaffold(
      appBar: AppBar(
        title: const Text('BILIM UZ'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CategoriesScreen()),
              );
            },
            icon: const Icon(Icons.category_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(homeControllerProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _HeroSection(
              title: 'Yaxshi kitoblar. Aniq narxlar. Tez buyurtma.',
              subtitle:
                  "Minimal, tez va qulay tajriba. Eng kerakli kitoblarni toping.",
              onSearch: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
              },
              onCategories: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            if (data != null && data.banners.isNotEmpty)
              _BannerCarousel(banners: data.banners),
            if (data != null && data.categories.isNotEmpty) ...[
              const SizedBox(height: 24),
              _CategorySection(
                categories: data.categories,
                onAll: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                  );
                },
              ),
            ],
            if (data != null && data.authors.isNotEmpty) ...[
              const SizedBox(height: 24),
              _AuthorSection(
                authors: data.authors,
                onAll: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AuthorsListScreen()),
                  );
                },
              ),
            ],
            if (data != null && data.featuredSections.isNotEmpty) ...[
              const SizedBox(height: 24),
              ...data.featuredSections.map((section) => _BookGridSection(
                    title: section.title,
                    onAll: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              CategoryBooksScreen(category: section.category),
                        ),
                      );
                    },
                    books: section.books,
                  )),
            ],
            if (data != null && data.newBooks.isNotEmpty) ...[
              const SizedBox(height: 24),
              _BookGridSection(title: "Yangi qo'shilganlar", books: data.newBooks),
            ],
            if (data != null && data.bestSelling.isNotEmpty) ...[
              const SizedBox(height: 24),
              _BookGridSection(
                title: "Eng ko'p sotilganlar",
                books: data.bestSelling,
              ),
            ],
            if (data != null && data.recommended.isNotEmpty) ...[
              const SizedBox(height: 24),
              _BookGridSection(
                title: 'Tavsiya etilganlar',
                books: data.recommended,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.title,
    required this.subtitle,
    required this.onSearch,
    required this.onCategories,
  });

  final String title;
  final String subtitle;
  final VoidCallback onSearch;
  final VoidCallback onCategories;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blue.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bilimstore',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: Colors.blue.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: onSearch,
                  child: const Text('Qidirish'),
                ),
                OutlinedButton(
                  onPressed: onCategories,
                  child: const Text('Kategoriyalar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerCarousel extends StatelessWidget {
  const _BannerCarousel({required this.banners});

  final List<BannerItem> banners;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        itemCount: banners.length,
        controller: PageController(viewportFraction: 0.92),
        itemBuilder: (context, index) {
          final banner = banners[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: banner.imageUrl == null
                  ? Container(
                      color: Colors.blue.shade50,
                      child: Center(
                        child: Text(
                          banner.title.isEmpty ? 'Banner' : banner.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    )
                  : Image.network(
                      banner.imageUrl!,
                      fit: BoxFit.cover,
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.categories, required this.onAll});

  final List<Category> categories;
  final VoidCallback onAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Kategoriyalar', onAll: onAll),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories
              .map(
                (category) => Chip(
                  label: Text(category.name),
                  backgroundColor: Colors.blue.shade50,
                  side: BorderSide(color: Colors.blue.shade100),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _AuthorSection extends StatelessWidget {
  const _AuthorSection({required this.authors, required this.onAll});

  final List<Author> authors;
  final VoidCallback onAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Mualliflar', onAll: onAll),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: authors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final author = authors[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AuthorDetailScreen(author: author),
                    ),
                  );
                },
                child: SizedBox(
                  width: 90,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundImage: author.photoUrl != null
                            ? NetworkImage(author.photoUrl!)
                            : null,
                        child: author.photoUrl == null
                            ? Text(author.name.characters.take(2).toString())
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        author.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BookGridSection extends StatelessWidget {
  const _BookGridSection({
    required this.title,
    required this.books,
    this.onAll,
  });

  final String title;
  final List<Book> books;
  final VoidCallback? onAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: title, onAll: onAll),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: books.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.6,
          ),
          itemBuilder: (context, index) {
            final book = books[index];
            return _BookCard(book: book);
          },
        ),
      ],
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BookDetailScreen(book: book),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: book.coverImageUrl == null
                  ? Container(
                      color: Colors.blue.shade50,
                      child: const Icon(Icons.menu_book, size: 48),
                    )
                  : Image.network(
                      book.coverImageUrl!,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            book.author?.name ?? '',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: Colors.grey.shade600),
          ),
          const Spacer(),
          Text(
            _formatPrice(book.salePrice),
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Colors.blue.shade700),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onAll});

  final String title;
  final VoidCallback? onAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        if (onAll != null)
          TextButton(
            onPressed: onAll,
            child: const Text('Hammasi'),
          ),
      ],
    );
  }
}

String _formatPrice(double? value) {
  if (value == null) {
    return '-';
  }
  return formatMoney(value);
}
