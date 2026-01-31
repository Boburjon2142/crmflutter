import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/books_controller.dart';
import '../providers.dart';
import '../shared/book_detail_screen.dart';
import '../ui/formatters.dart';

class BooksSearchResultsScreen extends ConsumerStatefulWidget {
  const BooksSearchResultsScreen({super.key, required this.query});

  final String query;

  @override
  ConsumerState<BooksSearchResultsScreen> createState() =>
      _BooksSearchResultsScreenState();
}

class _BooksSearchResultsScreenState
    extends ConsumerState<BooksSearchResultsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() {
      ref
          .read(
            booksControllerProvider(
              BooksQuery(query: widget.query),
            ).notifier,
          )
          .loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(
            booksControllerProvider(
              BooksQuery(query: widget.query),
            ).notifier,
          )
          .loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = BooksQuery(query: widget.query);
    final state = ref.watch(booksControllerProvider(query));

    return Scaffold(
      appBar: AppBar(title: Text('Qidiruv: "${widget.query}"')),
      body: state.isLoading && state.items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null && state.items.isEmpty
              ? _ErrorView(
                  message: state.errorMessage!,
                  onRetry: () => ref
                      .read(booksControllerProvider(query).notifier)
                      .loadInitial(),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(booksControllerProvider(query).notifier).refresh(),
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.6,
                    ),
                    itemCount: state.items.length + 1,
                    itemBuilder: (context, index) {
                      if (index == state.items.length) {
                        return _PaginationFooter(
                          isLoading: state.isLoadingMore,
                          hasNext: state.hasNext,
                        );
                      }
                      final book = state.items[index];
                      return _BookCard(
                        title: book.title,
                        author: book.author?.name ?? '',
                        price: _formatPrice(book.salePrice),
                        imageUrl: book.coverImageUrl,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BookDetailScreen(book: book),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({
    required this.title,
    required this.author,
    required this.price,
    required this.imageUrl,
    required this.onTap,
  });

  final String title;
  final String author;
  final String price;
  final String? imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl == null
                  ? Container(
                      color: Colors.blue.shade50,
                      child: const Icon(Icons.menu_book, size: 48),
                    )
                  : Image.network(imageUrl!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            author,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: Colors.grey.shade600),
          ),
          const Spacer(),
          Text(
            price,
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

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({required this.isLoading, required this.hasNext});

  final bool isLoading;
  final bool hasNext;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!hasNext) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: Text('Barchasi yuklandi')),
      );
    }
    return const SizedBox(height: 16);
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Qayta urinish'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatPrice(double? value) {
  if (value == null) {
    return '-';
  }
  return formatMoney(value);
}
