import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/authors/entities/author.dart';
import '../controllers/authors_controller.dart';
import '../providers.dart';
import 'author_detail_screen.dart';

class AuthorsListScreen extends ConsumerStatefulWidget {
  const AuthorsListScreen({super.key});

  @override
  ConsumerState<AuthorsListScreen> createState() => _AuthorsListScreenState();
}

class _AuthorsListScreenState extends ConsumerState<AuthorsListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(authorsControllerProvider.notifier).loadInitial();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(authorsControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authorsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mualliflar')),
      body: state.isLoading && state.items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null && state.items.isEmpty
              ? _ErrorView(
                  message: state.errorMessage!,
                  onRetry: () => ref
                      .read(authorsControllerProvider.notifier)
                      .loadInitial(),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(authorsControllerProvider.notifier).refresh(),
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.items.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == state.items.length) {
                        return _PaginationFooter(
                          isLoading: state.isLoadingMore,
                          hasNext: state.hasNext,
                        );
                      }
                      final author = state.items[index];
                      return _AuthorCard(author: author);
                    },
                  ),
                ),
    );
  }
}

class _AuthorCard extends StatelessWidget {
  const _AuthorCard({required this.author});

  final Author author;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: author.photoUrl != null
              ? NetworkImage(author.photoUrl!)
              : null,
          child: author.photoUrl == null
              ? Text(author.name.characters.take(2).toString())
              : null,
        ),
        title: Text(author.name),
        subtitle: Text(
          author.bio.isEmpty ? 'Biografiya mavjud emas' : author.bio,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: author.isFeatured
            ? const Icon(Icons.star, color: Colors.amber)
            : null,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AuthorDetailScreen(author: author),
            ),
          );
        },
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
